function merge_nested_add(node::Op.Type)
    @match node begin
        Op.Add(terms) => begin
            new_terms = Dict{Op.Type,Scalar.Type}()
            for (term, coeff) in terms
                @match term begin
                    Op.Add(inner_terms) => begin
                        for (inner_term, inner_coeff) in inner_terms
                            new_terms[inner_term] = canonicalize(
                                get(new_terms, inner_term, Num.Zero) + coeff * inner_coeff,
                            )
                        end
                    end
                    _ => begin
                        new_terms[term] = canonicalize(get(new_terms, term, Num.Zero) + coeff)
                    end
                end
            end
            return Op.Add(new_terms)
        end
        _ => return node
    end
end

function unbox_single_add(node::Op.Type)
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

function merge_group_element(node::Op.Type)
    @match node begin
        Op.Comm(base, Op.Comm(base, A, pow1), pow2) =>
            Op.Comm(base, A, canonicalize(pow1 + pow2))
        Op.AComm(base, Op.AComm(base, A, pow1), pow2) =>
            Op.AComm(base, A, canonicalize(pow1 + pow2))
        _ => node
    end
end

function merge_pow_mul(node::Op.Type)
    isa_variant(node, Op.Mul) || return node
    @match node begin
        Op.Mul(Op.Pow(base, exp1), Op.Pow(base, exp2)) =>
            Op.Pow(base, canonicalize(exp1 + exp2))
        _ => node
    end
end

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

function canonicalize(node::Op.Type)
    p = Post(
        Pre(
            Fixpoint(
                Chain(
                    merge_nested_add,
                    remove_add_zero_coeffs,
                    merge_group_element,
                    merge_pow_mul,
                    prop_adjoint,
                    break_outer,
                    unbox_single_add,
                );
                max_iter=10,
            ),
        ),
    )
    return p(node)
end
