# NOTE: just for tuning canonicalize
canonical_fixpoint(pass; max_iter::Int=4) = Fixpoint(pass; max_iter)

function canonicalize(node)
    return node
end

function canonicalize(node::Index.Type)
    p = Chain{Index.Type}(
        canonical_fixpoint(Pre(remove_empty_add)),
        canonical_fixpoint(Pre(merge_nested_mul)),
        canonical_fixpoint(Pre(merge_nested_add)),
        canonical_fixpoint(Pre(merge_mul_single_add)),
        canonical_fixpoint(Pre(merge_add_mul)),
        canonical_fixpoint(Pre(mul_to_pow)),
        canonical_fixpoint(Pre(merge_pow_mul)),
        canonical_fixpoint(Pre(prop_const_div)),
        canonical_fixpoint(Pre(remove_empty_add)),
        canonical_fixpoint(Pre(remove_pow_one)),
        canonical_fixpoint(Pre(fold_const_pow)),
        canonical_fixpoint(Pre(fold_const_add)),
        canonical_fixpoint(Pre(fold_const_mul)),
    )
    return p(node)
end

function canonicalize(node::Scalar.Type)
    p = Chain{Scalar.Type}(
        canonical_fixpoint(Post(merge_nested_add)),
        canonical_fixpoint(Post(merge_nested_mul)),
        canonical_fixpoint(Pre(merge_mul_single_add)),
        canonical_fixpoint(Post(merge_pow_mul)),
        canonical_fixpoint(Post(mul_to_pow)),
        canonical_fixpoint(Post(remove_pow_one)),
        canonical_fixpoint(Post(merge_add_mul)),
        canonical_fixpoint(Post(prop_const_div)),
        canonical_fixpoint(Pre(remove_empty_add)),
        canonical_fixpoint(Post(prop_conj)),
        canonical_fixpoint(Pre(fold_const_pow)),
        canonical_fixpoint(Pre(fold_const_add)),
        canonical_fixpoint(Pre(fold_const_mul)),
    )

    p = Chain{Scalar.Type}(
        canonical_fixpoint(p),
        Post(sort_terms(Scalar.Add)),
        Post(sort_terms(Scalar.Mul)),
        Post(fold_const_pow),
    )
    return p(node)
end

function canonicalize(node::Op.Type)
    p = Chain{Op.Type}(
        canonical_fixpoint(Pre(merge_nested_add)),
        canonical_fixpoint(Pre(remove_add_zero_coeffs)),
        canonical_fixpoint(Pre(merge_group_element)),
        canonical_fixpoint(Pre(merge_pow_mul)),
        canonical_fixpoint(Pre(prop_adjoint)),
        canonical_fixpoint(Pre(break_outer)),
        canonical_fixpoint(Pre(remove_empty_add)),
        canonical_fixpoint(Pre(fold_identity)),
        canonical_fixpoint(Pre(mul_to_pow)),
        canonical_fixpoint(Pre(merge_mul_add)),
    )
    return canonical_fixpoint(p)(node)
end
