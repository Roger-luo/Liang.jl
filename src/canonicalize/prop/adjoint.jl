function prop_adjoint(node::Op.Type)
    @match node begin
        # adjoint(a * A + b * B) = conj(a) * adjoint(A) + conj(b) * adjoint(B)
        Op.Adjoint(Op.Zero) => Op.Zero
        Op.Adjoint(Op.I) => Op.I
        Op.Adjoint(Op.X) => Op.X
        Op.Adjoint(Op.Y) => Op.Y
        Op.Adjoint(Op.Z) => Op.Z
        Op.Adjoint(Op.Sx) => Op.Sx
        Op.Adjoint(Op.Sy) => Op.Sy
        Op.Adjoint(Op.Sz) => Op.Sz
        Op.Adjoint(Op.H) => Op.H
        Op.Adjoint(Op.T) => Op.T

        Op.Adjoint(Op.Adjoint(A)) => A
        Op.Adjoint(Op.Add(terms)) => Op.Add(
            Dict{Op.Type,Scalar.Type}(term' => conj(coeff) for (term, coeff) in terms)
        )
        Op.Adjoint(Op.Mul(lhs, rhs)) => Op.Mul(lhs', rhs')
        Op.Adjoint(Op.Kron(lhs, rhs)) => Op.Kron(lhs', rhs')
        # ad_A^n(B) =
        # ad_A(B)' = ad_{A'}(B')
        # (AB - BA)' = B'A' - A'B' = -ad_{A'}(B') = ad_A(B)'
        # ad_A(ad_A(B))' = -ad_{A'}(ad_A(B)')
        # = ad_{A'}(ad_{A'}(B'))
        # ad_A^k(B)' = (-1)^k ad_{A'}^k(B')
        Op.Adjoint(Op.Comm(base, A, pow)) => Op.Add(
            Dict{Op.Type,Scalar.Type}(Op.Comm(base', A', pow) => canonicalize((-1)^pow))
        )
        Op.Adjoint(Op.AComm(base, A, pow)) => Op.AComm(base', A', pow)
        Op.Adjoint(Op.Pow(base, exp)) => Op.Pow(base', exp)
        Op.Adjoint(Op.KronPow(base, exp)) => Op.KronPow(base', exp)
        Op.Adjoint(Op.Subscript(base, idx)) => Op.Subscript(; op=base', indices=idx)
        Op.Adjoint(Op.Sum(region, indices, term)) => Op.Sum(region, indices, term')
        Op.Adjoint(Op.Prod(region, indices, term)) => Op.Prod(region, indices, term')
        Op.Adjoint(Op.Exp(A)) => Op.Exp(A')
        Op.Adjoint(Op.Log(A)) => Op.Log(A')
        Op.Adjoint(Op.Sqrt(A)) => Op.Sqrt(A')
        Op.Adjoint(Op.Conj(A)) => Op.Transpose(A)
        Op.Adjoint(Op.Transpose(A)) => Op.Conj(A)
        Op.Adjoint(Op.Outer(lhs, rhs)) => Op.Outer(rhs, lhs)
        Op.Adjoint(Op.Annotate(A, basis)) => Op.Annotate(A', basis)
        _ => node
    end
end
