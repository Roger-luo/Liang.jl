function decons_tuple(info::PatternInfo, pat::Pattern.Type)
    type_params = [isa_variant(x, Pattern.Quote) ? :($Base.typeof($(x.:1))) : Any for x in pat.xs]
    type = :($Base.Tuple{$(type_params...)})

    return function _tuple(value)
        return mapfoldl(and_expr, enumerate(pat.xs), init=:($value isa $type)) do (idx, x)
            decons(info, x)(:($value[$idx]))
        end
    end
end
