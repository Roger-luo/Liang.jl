function canonicalize(node::Index.Type)
    p = Chain(
        Fixpoint(Pre(remove_empty_add)),
        Fixpoint(Pre(merge_nested_mul)),
        Fixpoint(Pre(merge_nested_add)),
        Fixpoint(Pre(merge_add_mul)),
        Fixpoint(Pre(mul_to_pow)),
        Fixpoint(Pre(merge_pow_mul)),
        Fixpoint(Pre(prop_const_div)),
        Fixpoint(Pre(remove_empty_add)),
        Fixpoint(Pre(remove_pow_one)),
    )
    return p(node)
end

function canonicalize(node::Scalar.Type)
    p = Chain(
        Fixpoint(Post(merge_nested_add)),
        Fixpoint(Post(merge_nested_mul)),
        Fixpoint(Post(merge_pow_mul)),
        Fixpoint(Post(mul_to_pow)),
        Fixpoint(Post(remove_pow_one)),
        Fixpoint(Post(merge_add_mul)),
        Fixpoint(Post(prop_const_div)),
        Fixpoint(Pre(remove_empty_add)),
        Fixpoint(Post(prop_conj)),
    )

    p = Chain(
        Fixpoint(p),
        Post(sort_terms(Scalar.Add)),
        Post(sort_terms(Scalar.Mul)),
        Post(fold_const_pow),
    )
    return p(node)
end

function canonicalize(node::Op.Type)
    p = Chain(
        Fixpoint(Pre(merge_nested_add)),
        Fixpoint(Pre(remove_add_zero_coeffs)),
        Fixpoint(Pre(merge_group_element)),
        Fixpoint(Pre(merge_pow_mul)),
        Fixpoint(Pre(prop_adjoint)),
        Fixpoint(Pre(break_outer)),
        Fixpoint(Pre(remove_empty_add)),
    )
    return Fixpoint(p)(node)
end