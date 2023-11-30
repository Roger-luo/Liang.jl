for E in [Index, Scalar]
    @eval function remove_empty_add(node::$E.Type)
        isa_variant(node, $E.Add) || return node
        iszero(node.coeffs) || return node
        length(node.terms) == 1 || return node

        term, val = first(node.terms)
        if isone(val)
            return term
        else # val * term
            return node
        end
    end
end # for E in [Index, Scalar]

function remove_empty_add(node::Op.Type)
    @match node begin
        Op.Add(terms) => begin
            length(terms) == 1 || return node
            (term, coeff) = first(terms)
            isone(coeff) || return node
            return term
        end
        _ => return node
    end
end

function remove_add_zero_coeffs(node::Op.Type)
    @match node begin
        Op.Add(terms) => begin
            new_terms = Dict{Op.Type,Scalar.Type}()
            for (term, coeff) in terms
                iszero(coeff) && continue
                term == Op.Zero && continue
                new_terms[term] = coeff
            end
            isempty(new_terms) && return Op.Zero
            return Op.Add(new_terms)
        end
        _ => return node
    end
end
