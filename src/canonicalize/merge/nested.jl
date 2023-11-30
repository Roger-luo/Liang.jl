for (E, V) in [(Scalar, Num.Type), (Index, Int64)]
    @eval begin
        function merge_nested(update_coeffs_f, ::Type{$E.Type}, variant_type)
            function transform(node::$E.Type)
                isa_variant(node, variant_type) || return node
                coeffs = node.coeffs
                terms = ACSet{$E.Type,$V}()

                for (term, val) in node.terms
                    if isa_variant(term, variant_type)
                        # (coeffs * prod[sub_terms^sub_val])^val
                        # = coeffs^val * prod[sub_terms^(sub_val + val)]
                        coeffs = update_coeffs_f(coeffs, term.coeffs, val)
                        for (sub_term, sub_val) in term.terms
                            terms[sub_term] = sub_val * val
                        end
                    else
                        terms[term] = val
                    end
                end
                return variant_type(coeffs, terms)
            end
        end

        """
        $SIGNATURES

        This merge nested `$($E).Mul` nodes if possible.
        """
        function merge_nested_mul(node::$E.Type)
            transform = merge_nested($E.Type, $E.Mul) do coeffs, term_coeffs, val
                # coeffs * (term.coeffs * prod[sub_terms[i]^sub_val[i]])^val
                # = coeffs*term.coeffs^val * prod[sub_terms[i]^(sub_val[i]*val)]
                coeffs * term_coeffs^val
            end
            return transform(node)
        end

        """
        $SIGNATURES

        Merge nested `$($E).Add` nodes if possible.
        """
        function merge_nested_add(node::$E.Type)
            transform = merge_nested($E.Type, $E.Add) do coeffs, term_coeffs, val
                # val * (term.coeffs + sum[sub_val[i] * sub_terms[i]])
                # = val * term.coeffs + sum[val * sub_val[i] * sub_terms[i]]
                coeffs + val * term_coeffs
            end
            return transform(node)
        end
    end # @eval
end # for E in [Scalar.Type, Index.Type]

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
