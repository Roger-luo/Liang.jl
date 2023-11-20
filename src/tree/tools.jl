function map_ac_set(f, op, terms::Dict{E, V}) where {E, V}
    new_terms = Dict{E,V}()
    for (key, val) in terms
        new_key = f(key)
        if haskey(new_terms, new_key)
            new_terms[new_key] = op(new_terms[new_key], val)
        else
            new_terms[new_key] = val
        end
    end
    return new_terms
end

function threaded_map_ac_set(f, terms::Dict{E, V}) where {E, V}
    mapped_pairs = tcollect(terms |> Map(p->(f(p.first) => p.second)))

    new_terms = Dict{E,V}()
    for (key, val) in mapped_pairs
        if haskey(new_terms, new_key)
            new_terms[key] = op(new_terms[key], val)
        else
            new_terms[key] = val
        end
    end
    return new_terms
end
