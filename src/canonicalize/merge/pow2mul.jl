for (E, V) in [(Index, Int), (Scalar, Num.Type)]
    @eval begin
        """
        $SIGNATURES

        Merge `$($E).Pow` into `$($E).Mul`.
        """
        function merge_pow_mul(node::$E.Type)
            isa_variant(node, $E.Mul) || return node
            coeffs = node.coeffs
            terms = ACSet{$E.Type,$V}()
            for (term, val) in node.terms
                @match term begin
                    $E.Pow(base, $E.Constant(exp)) => (terms[term.base] = term.exp * val)
                    _ => (terms[term] = val)
                end
            end
            return $E.Mul(coeffs, terms)
        end
    end # @eval
end # for E in [Index, Scalar]

function merge_pow_mul(node::Op.Type)
    isa_variant(node, Op.Mul) || return node
    @match node begin
        Op.Mul(Op.Pow(base, exp1), Op.Pow(base, exp2)) =>
            Op.Pow(base, canonicalize(exp1 + exp2))
        _ => node
    end
end
