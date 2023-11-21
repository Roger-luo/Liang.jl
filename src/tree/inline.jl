inline_print(node) = inline_print(stdout, node)

function inline_print(io::IO, node)
    use_custom_print(node) && return custom_inline_print(io, node)

    subnodes = children(node)
    parent_pred = get(io, :precedence, 0)
    node_pred = precedence(node)
    if is_leaf(node)
        print_node(io, node)
    elseif is_infix(node) # must be binary op
        @assert length(subnodes) == 2
        left, right = subnodes
        sub_io = IOContext(io, :precedence => node_pred)
        node_pred < parent_pred && print(io, "(")
        inline_print(sub_io, left)
        print_node(io, node)
        inline_print(sub_io, right)
        node_pred < parent_pred && print(io, ")")
    else # print as a call
        print_node(io, node)
        print(io, "(")
        for (idx, subnode) in enumerate(subnodes)
            idx > 1 && print(io, ", ")
            inline_print(io, subnode)
        end
        print(io, ")")
    end
    return nothing
end
