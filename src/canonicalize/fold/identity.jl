function fold_identity(node::Op.Type)
    @match node begin
        Op.Mul(Op.I, X) || Op.Mul(X, Op.I) => X
        Op.Mul(Op.Subscript(Op.I, idx_a), Op.Subscript(Op.I, idx_b)) =>
            Op.Subscript(Op.I, [idx_a..., idx_b...])
        Op.Mul(Op.Subscript(Op.I, _), X) || Op.Mul(X, Op.Subscript(Op.I, _)) => X
        _ => node
    end
end
