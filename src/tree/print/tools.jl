function print_add(io::IO, terms::AbstractDict)
    parent_pred = get(io, :precedence, 0)
    node_pred = Base.operator_precedence(:+)
    parent_pred > node_pred && print(io, "(")

    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        if !isone(coeff)
            print(io, coeff, "*")
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:*))
        else
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:+))
        end
        inline(sub_io, term)
        if idx < length(terms)
            print(io, "+")
        end
    end

    parent_pred > node_pred && print(io, ")")
    return nothing
end

function print_mul(io::IO, terms::AbstractDict)
    parent_pred = get(io, :precedence, 0)
    node_pred = precedence(:+)
    parent_pred > node_pred && print(io, "(")

    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        if !isone(coeff)
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:^))
            inline(sub_io, term)
            print(io, "^", coeff)
        else
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:*))
            inline(sub_io, term)
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

function inline_list(io::IO, list, delim::AbstractString=", ", cutoff::Int=4)
    if length(list) <= cutoff # print all elements
        for (i, item) in enumerate(list)
            show(io, item)
            if i < length(list)
                print(io, delim)
            end
        end
    else # print first 2 and last 2 elements
        for (i, item) in enumerate(list[1:2])
            show(io, item)
            if i < 2
                print(io, delim)
            end
        end
        print(io, delim, "...")
        for (i, item) in enumerate(list[(end - 1):end])
            print(io, delim)
            show(io, item)
        end
    end
end
