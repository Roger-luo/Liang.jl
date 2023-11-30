for E in [Index, Scalar]
    @eval function remove_empty_add(node::$E.Type)
        isa_variant(node, $E.Add) || return node
        iszero(node.coeffs) || return node
        length(node.terms) == 1 || return node

        term, val = first(node.terms)
        if isone(val)
            return term
        else # val * term
            return node
        end
    end
end # for E in [Index, Scalar]
