function emit(info::EmitInfo)
    matches = expr_map(info.patterns, info.exprs) do pat, expr
        cond, assigns = emit_decons(info, pat)

        quote
            if $cond
                $(info.return_var) = let $(assigns...)
                    $expr
                end
                @goto $(info.final_label)
            end
        end
    end

    quote
        $(info.value_holder) = $(info.value)
        $matches
        @label $(info.final_label)
        $(info.return_var)
    end
end

and_expr(lhs, rhs) = quote
    $lhs && $rhs
end

struct PatternInfo
    emit::EmitInfo
    scope::Dict{Symbol, Set{Symbol}}
end

PatternInfo(info::EmitInfo) = PatternInfo(info, Dict{Symbol, Set{Symbol}}())

function Base.setindex!(info::PatternInfo, v::Symbol, k::Symbol)
    push!(get!(Set{Symbol}, info.scope, k), v)
    return info
end

function decons(info::PatternInfo, pat::Pattern.Type)
    return function value_assigned(x)
        @gensym value
        return quote
            $value = $x
            $(inner_decons(info, pat)(value))
        end
    end
end

function inner_decons(info::PatternInfo, pat::Pattern.Type)
    isa_variant(pat, Pattern.Wildcard) && return decons_wildcard(info, pat)
    isa_variant(pat, Pattern.Variable) && return decons_variable(info, pat)
    isa_variant(pat, Pattern.Quote) && return decons_quote(info, pat)
    isa_variant(pat, Pattern.And) && return decons_and(info, pat)
    isa_variant(pat, Pattern.Or) && return decons_or(info, pat)
    isa_variant(pat, Pattern.Ref) && return decons_ref(info, pat)
    isa_variant(pat, Pattern.Call) && return decons_call(info, pat)
    isa_variant(pat, Pattern.Tuple) && return decons_tuple(info, pat)
    isa_variant(pat, Pattern.Vector) && return decons_untyped_vect(info, pat)
    isa_variant(pat, Pattern.Splat) && return decons_splat(info, pat)
    isa_variant(pat, Pattern.TypeAnnotate) && return decons_type_annotate(info, pat)

    error("invalid pattern: $pat")
end

function decons_wildcard(info::PatternInfo, pat::Pattern.Type)
    return function wildcard(value)
        return true
    end
end

function decons_variable(info::PatternInfo, pat::Pattern.Type)
    return function variable(value)
        # NOTE: this is used to create a scope
        # using let ... end later, so we cannot
        # directly assign it to the pattern variable
        placeholder = gensym()
        info[pat.:1] = placeholder
        return quote
            $(placeholder) = $value
            true
        end
    end
end

function decons_quote(info::PatternInfo, pat::Pattern.Type)
    return function _quote(value)
        return quote
            $value == $(pat.:1)
        end
    end
end

function decons_and(info::PatternInfo, pat::Pattern.Type)
    return function and(value)
        return quote
            $(decons(info, pat.:1)(value)) && $(decons(info, pat.:2)(value))
        end
    end
end

function decons_or(info::PatternInfo, pat::Pattern.Type)
    return function or(value)
        return quote
            $(decons(info, pat.:1)(value)) || $(decons(info, pat.:2)(value))
        end
    end
end

function decons_ref(info::PatternInfo, pat::Pattern.Type)
    # NOTE: we generate both cases here, because Julia should
    # be able to eliminate one of the branches during compile
    # NOTE: ref syntax <symbol> [<elem>...] has the following cases:
    # 1. <symbol> is defined, and is a type, typed vect
    # 2. <symbol> is not defined in global scope as type,
    #    but is defined as a variable, getindex, the match
    #    will try to find the index that returns the input
    #    value.
    # 2 is not supported for now because I don't see any use case.
    return decons_vect(info, pat, :($value isa $Base.Vector{$head}))
end

function decons_call(info::PatternInfo, pat::Pattern.Type)
    # NOTE: when we see a call, it can only be a constructor
    # because our syntactical pattern match is performed on data only
    # args => get field by index, then compare
    # kwargs => get field by name, then compare

    # struct Call
    #     head # must be constant object
    #     args::Vector{Pattern}
    #     kwargs::Dict{Symbol, Pattern}
    # end

    # we need to special case data type because Julia types
    # do not share a common interface with our ADT for getting
    # numbered fields, e.g getproperty(x, ::Int) is not defined for
    # Julia types in general.
    @gensym value
    nfields = length(pat.args) + length(pat.kwargs)
    head = Base.eval(info.emit.mod, pat.head)
    if Data.is_datatype(head) # check if our pattern is correct
        Data.variant_nfields(head) >= nfields || throw(SyntaxError("invalid pattern: $pat"))
        Data.variant_kind(head) == Data.Anonymous && length(pat.kwargs) > 0 && throw(SyntaxError("invalid pattern: $pat"))

        type_assert = :($Data.isa_variant($value, $head))
        args_conds = mapfoldl(and_expr, enumerate(pat.args), init=true) do (idx, x)
            decons(info, x)(:($Base.getproperty($value, $idx)))
        end
        kwargs_conds = mapfoldl(and_expr, pat.kwargs, init=true) do kw
            key, val = kw
            decons(info, val)(:($Base.getproperty($value, $key)))
        end
    else
        Base.fieldcount(head) >= nfields || throw(SyntaxError("too many fields to match: $pat"))

        type_assert = :($value isa $head)
        args_conds = mapfoldl(and_expr, enumerate(pat.args), init=true) do (idx, x)
            decons(info, x)(:($Core.getfield($value, $idx)))
        end
        kwargs_conds = mapfoldl(and_expr, pat.kwargs, init=true) do kw
            key, val = kw
            decons(info, val)(:($Core.getfield($value, $key)))
        end
    end

    return function call(x)
        return quote
            $value = $x
            $type_assert && $args_conds && $kwargs_conds
        end
    end
end

function decons_tuple(info::PatternInfo, pat::Pattern.Type)
    type_params = [isa_variant(x, Pattern.Quote) ? :($Base.typeof($(x.:1))) : Any for x in pat.xs]
    type = :($Base.Tuple{$(type_params...)})

    return function _tuple(value)
        return mapfoldl(and_expr, enumerate(pat.xs), init=:($value isa $type)) do (idx, x)
            decons(info, x)(:($value[$idx]))
        end
    end
end

function decons_untyped_vect(info::PatternInfo, pat::Pattern.Type)
    return decons_vect(info, pat, true)
end

function decons_vect(info::PatternInfo, pat::Pattern.Type, type)
    return function ref(value)
        @gensym head

        vect_decons = mapfoldl(
            and_expr,
            enumerate(pat.args),
            init=type
        ) do (idx, x)
            decons(info, x)(:($value[$idx]))
        end

        return quote
            $head = $(pat.head)
            if $head isa Type
                $vect_decons
            else
                throw(ArgumentError("invalid type: $($head)"))
            end
        end
    end
end

function decons_splat(info::EmitInfo, pat::Pattern.Type)
    return function splat(value)
    end
end

function decons_type_annotate(info::EmitInfo, pat::Pattern.Type)
    return function annotate(value)
        and_expr(
            :($value isa $(pat.type)),
            decons(info, pat.body)(value)
        )
    end
end
