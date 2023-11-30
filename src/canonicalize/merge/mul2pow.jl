for (E, One) in [(Index, 1), (Scalar, Num.One)]
    @eval begin
        """
        $SIGNATURES

        Converts `$($E).Mul` with single child to `$($E).Pow`.
        """
        function mul_to_pow(node::$E.Type)
            isa_variant(node, $E.Mul) || return node
            if Tree.n_children(node) == 1 # convert to Sum/Pow
                if node.coeffs == $One
                    term, val = first(node.terms)
                    return $E.Pow(term, val)
                end
            end
            return node
        end
    end # @eval
end # for E in [Index, Scalar]
