function fold_identity(node::Op.Type)
    @match node begin
        Op.Mul(Op.I, X) || Op.Mul(X, Op.I) => X
        _ => node
    end
end
