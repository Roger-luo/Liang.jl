inline(node) = inline(stdout, node)

function inline(io::IO, node)
    use_custom_print(node) && return custom_inline_print(io, node)

    subnodes = children(node)
    parent_pred = get(io, :precedence, 0)
    node_pred = precedence(node)
    if Tree.is_leaf(node)
        node_pred < parent_pred && print(io, "(")
        print_node(io, node)
        node_pred < parent_pred && print(io, ")")
    elseif is_prefix(node)
        @assert length(subnodes) == 1
        sub_io = IOContext(io, :precedence => node_pred)
        node_pred < parent_pred && print(io, "(")
        print_node(io, node)
        inline(sub_io, subnodes[1])
        node_pred < parent_pred && print(io, ")")
    elseif is_infix(node) # must be binary op
        @assert length(subnodes) == 2
        left, right = subnodes
        sub_io = IOContext(io, :precedence => node_pred)
        node_pred < parent_pred && print(io, "(")
        inline(sub_io, left)
        print_node(io, node)
        inline(sub_io, right)
        node_pred < parent_pred && print(io, ")")
    elseif is_postfix(node)
        @assert length(subnodes) == 1
        sub_io = IOContext(io, :precedence => node_pred)
        inline(sub_io, subnodes[1])
        print_node(io, node)
    else # print as a call
        print_node(io, node)
        print(io, "(")
        for (idx, subnode) in enumerate(subnodes)
            idx > 1 && print(io, ", ")
            inline(io, subnode)
        end
        print(io, ")")
    end
    return nothing
end
