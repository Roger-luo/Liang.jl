for (E, One) in [(Index, 1), (Scalar, Num.One)]
    @eval begin
        """
        $SIGNATURES

        This removes `$($E).Pow` nodes with exponent `1`.
        """
        function remove_pow_one(node::$E.Type)
            isa_variant(node, $E.Pow) || return node
            if node.exp == $One
                return node.base
            end
            return node
        end
    end # @eval
end # for E in [Index, Scalar]
