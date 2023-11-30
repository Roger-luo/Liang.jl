"""
$SIGNATURES

Propagate constant division into `Scalar.Add` and `Scalar.Mul`.
"""
function prop_const_div(node::Scalar.Type)
    @match node begin
        Scalar.Div(Scalar.Add(coeffs, terms), Scalar.Constant(den)) => begin
            new_coeffs = coeffs / den
            new_terms = Dict{Scalar.Type,Num.Type}()
            for (term, val) in terms
                new_terms[term] = val / den
            end
            return Scalar.Add(new_coeffs, ACSet(new_terms))
        end

        Scalar.Div(Scalar.Mul(coeffs, terms), Scalar.Constant(den)) => begin
            return Scalar.Mul(coeffs / den, terms)
        end

        _ => return node
    end
end

"""
$SIGNATURES

Propagate constant division into `Index.Add` and `Index.Mul`.
"""
function prop_const_div(node::Index.Type)
    @match node begin
        Index.Div(Index.Add(coeffs, terms), Index.Constant(den)) => begin
            new_coeffs = coeffs ÷ den
            new_terms = Dict{Index.Type,Int}()
            for (term, val) in terms
                new_terms[term] = val ÷ den
            end
            return Index.Add(new_coeffs, ACSet(new_terms))
        end

        Index.Div(Index.Mul(coeffs, terms), Index.Constant(den)) => begin
            return Index.Mul(coeffs ÷ den, terms)
        end

        _ => return node
    end
end
