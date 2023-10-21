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
