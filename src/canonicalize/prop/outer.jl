function break_outer(node::Op.Type)
    @match node begin
        Op.Outer(State.Add(lhs_terms), State.Add(rhs_terms)) => begin
            terms = Dict{Op.Type,Scalar.Type}()
            for (lhs_state, lhs_coeff) in lhs_terms, (rhs_state, rhs_coeff) in rhs_terms
                terms[Op.Outer(lhs_state, rhs_state)] = lhs_coeff * rhs_coeff
            end
            return Op.Add(terms)
        end
        Op.Outer(State.Add(lhs_terms), rhs) => begin
            terms = Dict{Op.Type,Scalar.Type}()
            for (lhs_state, lhs_coeff) in lhs_terms
                terms[Op.Outer(lhs_state, rhs)] = lhs_coeff
            end
            return Op.Add(terms)
        end
        Op.Outer(lhs, State.Add(rhs_terms)) => begin
            terms = Dict{Op.Type,Scalar.Type}()
            for (rhs_state, rhs_coeff) in rhs_terms
                terms[Op.Outer(lhs, rhs_state)] = rhs_coeff
            end
            return Op.Add(terms)
        end
        _ => node
    end
end
