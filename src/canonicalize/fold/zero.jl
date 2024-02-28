function fold_zero(node::Op.Type)
    @match node begin
        Op.Mul(Op.Zero, X) || Op.Mul(X, Op.Zero) => Op.Zero
        Op.Mul(Op.Subscript(Op.Zero, idx), _) || Op.Mul(_, Op.Subscript(Op.Zero, idx)) =>
            Op.Zero
        Op.Kron(Op.Zero, X) || Op.Kron(X, Op.Zero) => Op.Zero
        Op.Pow(Op.Zero, _) => Op.Zero
        Op.Pow(Op.Subscript(Op.Zero, _), _) => Op.Zero
        Op.Add(terms) => begin
            new_terms = ACSet{Op.Type,Scalar.Type}()
            for (key, val) in terms
                @match key begin
                    Op.Zero => continue
                    Op.Subscript(Op.Zero, _) => continue
                    _ => nothing
                end
                new_terms[key] = val
            end
            return Op.Add(new_terms)
        end
        _ => node
    end
end
