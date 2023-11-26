function print_add(io::IO, terms::Dict)
    parent_pred = get(io, :precedence, 0)
    node_pred = Base.operator_precedence(:+)
    parent_pred > node_pred && print(io, "(")

    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        if !isone(coeff)
            Tree.inline_print(io, coeff)
            print(io, "*")
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:*))
        else
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:+))
        end
        Tree.inline_print(sub_io, term)
        if idx < length(terms)
            print(io, "+")
        end
    end

    parent_pred > node_pred && print(io, ")")
    return nothing
end

function print_mul(io::IO, terms::Dict)
    parent_pred = get(io, :precedence, 0)
    node_pred = Tree.precedence(:+)
    parent_pred > node_pred && print(io, "(")

    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        if !isone(coeff)
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:^))
            Tree.inline_print(sub_io, term)
            print(io, "^")
            Tree.inline_print(io, coeff)
        else
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:*))
            Tree.inline_print(sub_io, term)
        end

        if idx < length(terms)
            print(io, "*")
        end
    end
    parent_pred > node_pred && print(io, ")")
    return nothing
end

function print_variable(io::IO, name::Symbol, id::UInt64)
    if id > 0 # SSA var
        print(io, "%", id)
    else
        print(io, name)
    end
end

function print_list(io::IO, list, delim::AbstractString=", ", cutoff::Int=4)
    if length(list) <= cutoff # print all elements
        for (i, item) in enumerate(list)
            inline_print(io, item)
            if i < length(list)
                print(io, delim)
            end
        end
    else # print first 2 and last 2 elements
        for (i, item) in enumerate(list[1:2])
            inline_print(io, item)
            if i < 2
                print(io, delim)
            end
        end
        print(io, delim, "...")
        for (i, item) in enumerate(list[(end - 1):end])
            print(io, delim)
            inline_print(io, item)
        end
    end
end

function map_ac_set(f, op, terms::Dict{E,V}) where {E,V}
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

function threaded_map_ac_set(f, terms::Dict{E,V}) where {E,V}
    mapped_pairs = tcollect(Map(p -> (f(p.first) => p.second))(terms))

    new_terms = Dict{E,V}()
    for (key, val) in mapped_pairs
        if haskey(new_terms, key)
            new_terms[key] = op(new_terms[key], val)
        else
            new_terms[key] = val
        end
    end
    return new_terms
end
