for (E, V) in [(Index, Int), (Scalar, Num.Type)]
    @eval begin
        function fold_const_pow(node::$E.Type)
            @match node begin
                $E.Pow($E.Constant(x), $E.Constant(y)) => return $E.Constant(x^y)
                _ => return node
            end
        end

        function fold_const_add(node::$E.Type)
            isa_variant(node, $E.Add) || return node
            new_coeffs = node.coeffs
            new_terms = ACSet{$E.Type,$V}()
            for (term, coeff) in node.terms
                @match term begin
                    $E.Constant(x) => (new_coeffs += x * coeff)
                    _ => (new_terms[term] = coeff)
                end
            end
            return $E.Add(new_coeffs, new_terms)
        end

        function fold_const_mul(node::$E.Type)
            isa_variant(node, $E.Mul) || return node
            new_coeffs = node.coeffs
            new_terms = ACSet{$E.Type,$V}()
            for (term, coeff) in node.terms
                @match term begin
                    $E.Constant(x) => (new_coeffs *= x^coeff)
                    _ => (new_terms[term] = coeff)
                end
            end
            return $E.Mul(new_coeffs, new_terms)
        end
    end # @eval begin
end # for (E, V) in [(Index, Int), (Scalar, Num.type)]
