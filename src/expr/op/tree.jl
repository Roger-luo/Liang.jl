function Tree.children(node::Op.Type)
    @match node begin
        Op.Add(_, terms) => collect(Op.Type, keys(terms))
        Op.Mul(lhs, rhs) => [lhs, rhs]
        Op.Kron(lhs, rhs) => [lhs, rhs]
        Op.Comm(base, op, pow) => [base, op]
        Op.AComm(base, op, pow) => [base, op]
        Op.Pow(base, exp) => [base]
        Op.KronPow(base, exp) => [base]
        Op.Adjoint(op) => [op]
        Op.Subscript(op, _) => [op]
        Op.Sum(_, term) => [term]
        Op.Prod(_, term) => [term]
        Op.Exp(op) => [op]
        Op.Log(op) => [op]
        Op.Tr(op) => [op]
        Op.Det(op) => [op]
        Op.Inv(op) => [op]
        Op.Sqrt(op) => [op]
        Op.Transpose(op) => [op]
        Op.Annotate(expr) => [expr]
        _ => Op.Type[]
    end
end

function Tree.substitute(node::Op.Type, replace::Dict{Op.Type, Op.Type})
    @match node begin
    end
end
