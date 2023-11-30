for (E, One) in [(Index, 1), (Scalar, Num.One)]
    @eval begin
        """
        $SIGNATURES

        This removes `$($E).Pow` nodes with exponent `1`.
        """
        function remove_pow_one(node::$E.Type)
            @match node begin
                $E.Pow(base, $E.Constant($One)) => return base
                _ => return node
            end
        end
    end # @eval
end # for E in [Index, Scalar]
