function decons_tuple(info::PatternInfo, pat::Pattern.Type)
    type = tuple_pattern_type(info, pat)

    n_splats = count(x -> isa_variant(x, Pattern.Splat), pat.xs)
    n_splats > 1 && error("multiple splats in tuple pattern")
    n_splats == 0 && return basic_tuple(info, pat, type)

    return splat_tuple(info, pat)
end

function basic_tuple(info::PatternInfo, pat::Pattern.Type, type)
    return function tuple(value)
        return mapfoldl(and_expr, enumerate(pat.xs); init=:($value isa $type)) do (idx, x)
            decons(info, x)(:($value[$idx]))
        end
    end
end

function splat_tuple(info::PatternInfo, pat::Pattern.Type)
    # NOTE: we use splat as the terminator of our loop
    return function tuple(value)
        stmts = []
        splat_idx = 0
        for (idx, p) in enumerate(pat.xs)
            splat_idx = idx
            isa_variant(p, Pattern.Splat) && break
            push!(stmts, decons(info, p)(:($value[$idx])))
        end

        # match splat
        p = pat.xs[splat_idx]
        @gensym placeholder
        stmt = if splat_idx == length(pat.xs) # splat is last
            quote
                $placeholder = $value[$splat_idx:end]
                true
            end
        else
            nleft = length(pat.xs) - splat_idx
            quote
                $placeholder = $value[$splat_idx:end-$nleft]
                true
            end
        end
        push!(stmts, stmt)
        if isa_variant(p.body, Pattern.TypeAnnotate)
            @gensym N
            push!(stmts, quote
                $placeholder isa NTuple{$N, $(p.body.type)} where $N
            end)
            push!(stmts, decons(info, p.body.body)(placeholder))
        else
            push!(stmts, decons(info, p.body)(placeholder))
        end

        for (idx, p) in enumerate(reverse(pat.xs))
            isa_variant(p, Pattern.Splat) && break
            stmt = if idx == 1
                decons(info, p)(:($value[end]))
            else
                decons(info, p)(:($value[end-$(idx - 1)]))
            end
            push!(stmts, stmt)
        end

        min_length = length(pat.xs) - 1
        return foldl(
            and_expr, stmts,
            init=:($value isa $Base.Tuple && length($value) >= $min_length),
        )
    end
end

function assert_tuple_pattern(info::PatternInfo, pat::Pattern.Type)
    if count(x -> isa_variant(x, Pattern.Splat), pat.xs) > 1
        error("multiple splats in tuple pattern")
    end
end

function tuple_pattern_type(info::PatternInfo, pat::Pattern.Type)
    type_params = map(pat.xs) do x
        if isa_variant(x, Pattern.Quote)
            :($Base.typeof($(x.:1)))
        else
            Any
        end
    end
    return :($Base.Tuple{$(type_params...)})
end
