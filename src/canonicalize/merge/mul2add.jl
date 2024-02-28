for (E, V, One) in [(Index, Int, 1), (Scalar, Num.Type, Num.One)]
    @eval begin
        """
        $SIGNATURES

        This move coeffs of a `$($E).Mul` into its children
        `$($E).Add` if only has one, e.g `a * (b + c) -> a * b + a * c`.

        !!! note
            This is a special case because in general expanding addition
            will increase the size exponentially. Thus should be called by
            user explicitly.
        """
        function merge_mul_single_add(node::$E.Type)
            isa_variant(node, $E.Mul) || return node
            coeffs = node.coeffs
            multiplication_terms = ACSet{$E.Type,$V}()
            addition_terms = Dict{$E.Type,$V}()

            for (term, val) in node.terms
                if isa_variant(term, $E.Add)
                    addition_terms[term] = val
                else
                    multiplication_terms[term] = val
                end
            end # for (term, val) in node.terms

            isempty(addition_terms) && return node # no add
            length(addition_terms) > 1 && return node # more than one add

            add_term, add_val = first(addition_terms)
            isone(add_val) || return node # not a single add

            new_terms = ACSet{$E.Type,$V}()
            for (term, val) in add_term.terms
                subterms = copy(multiplication_terms)
                subterms[term] = $One
                new_terms[$E.Mul($One, subterms)] = val * coeffs
            end

            if !iszero(add_term.coeffs * coeffs)
                new_terms[$E.Mul($One, multiplication_terms)] = add_term.coeffs * coeffs
            end
            return $E.Add(zero($E.Type), new_terms)
        end
    end # @eval
end

function merge_mul_add(node::Op.Type)
    @match node begin
        Op.Mul(A, Op.Add(terms)) => begin
            new_terms = ACSet{Op.Type,Scalar.Type}()
            for (term, val) in terms
                new_terms[A * term] = val
            end
            return Op.Add(new_terms)
        end
        Op.Mul(Op.Add(terms), B) => begin
            new_terms = ACSet{Op.Type,Scalar.Type}()
            for (term, val) in terms
                new_terms[term * B] = val
            end
            return Op.Add(new_terms)
        end
        _ => node
    end
end
