function merge_subscript(node::Op.Type)
    # some operator adapt to number of sites
    @match node begin
        Op.Mul(Op.Subscript(Op.I, idx_a), Op.Subscript(A, idx_b)) =>
            Op.Subscript(Op.I, [idx_a..., idx_b...])
        Op.Mul(Op.Subscript(Op.Zero, idx_a), Op.Subscript(A, idx_b)) =>
            Op.Subscript(Op.Zero, [idx_a..., idx_b...])
        _ => node
    end
end
