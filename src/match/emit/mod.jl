function emit(info::EmitInfo)
    matches = expr_map(info.cases, info.exprs) do case, expr
        pinfo = PatternInfo(info)
        cond = decons(pinfo, case)(info.value_holder)

        quote
            if $cond && $(check_duplicated_variables(pinfo))
                $(info.return_var) = let $(bind_match_values(pinfo)...)
                    $expr
                end
                @goto $(info.final_label)
            end
        end
    end

    quote
        $(info.value_holder) = $(info.value)
        $matches
        error("matching non-exhaustic")
        @label $(info.final_label)
        $(info.return_var)
    end
end

and_expr(lhs, rhs) = quote
    $lhs && $rhs
end

struct PatternInfo
    emit::EmitInfo
    scope::Dict{Symbol,Set{Symbol}}
end

PatternInfo(info::EmitInfo) = PatternInfo(info, Dict{Symbol,Set{Symbol}}())

function Base.setindex!(info::PatternInfo, v::Symbol, k::Symbol)
    push!(get!(Set{Symbol}, info.scope, k), v)
    return info
end

function check_duplicated_variables(info::PatternInfo)
    stmts = []
    for (var, values) in info.scope
        length(values) > 1 || continue
        # NOTE: let's just not support 1.8-
        val_expr = xtuple(values...)
        push!(stmts, :($Base.allequal($val_expr)))
    end
    return foldl(and_expr, stmts; init=true)
end

function bind_match_values(info::PatternInfo)
    return map(collect(keys(info.scope))) do k
        :($k = $(first(info.scope[k])))
    end
end

include("decons.jl")
include("collect.jl")
include("leafs.jl")
include("logic.jl")
include("call.jl")
include("tuple.jl")
include("vect.jl")

function decons_type_annotate(info::PatternInfo, pat::Pattern.Type)
    return function annotate(value)
        return and_expr(:($value isa $(pat.type)), decons(info, pat.body)(value))
    end
end
