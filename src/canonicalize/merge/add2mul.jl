for (E, V, One) in [(Index, Int, 1), (Scalar, Num.Type, Num.One)]
    @eval begin
        """
        $SIGNATURES

        This move coeffs of a `$($E).Mul` into its parent
        `$($E).Add` if possible.
        """
        function merge_add_mul(node::$E.Type)
            isa_variant(node, $E.Add) || return node
            coeffs = node.coeffs
            terms = ACSet{$E.Type,$V}()
            for (term, val) in node.terms
                if isa_variant(term, $E.Mul)
                    # + val * (coeffs * prod[sub_terms[i]^sub_val[i]])
                    # = + (val * coeffs) * prod[sub_terms^sub_val]
                    new_key = $E.Mul($One, term.terms)
                    terms[new_key] = val * term.coeffs
                else
                    terms[term] = val
                end
            end
            return $E.Add(coeffs, terms)
        end
    end # @eval
end # for E in [Index, Scalar]
