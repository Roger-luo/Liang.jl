for op in (:<, :<=, :>, :>=, :isless)
    @eval begin
        function Base.$op(lhs::Num.Type, rhs::Num.Type)
            @match (lhs, rhs) begin
                (Num.Zero, Num.Zero) => $op(0, 0)
                (Num.Zero, Num.One) => $op(0, 1)
                (Num.Zero, Num.Real(y)) => $op(0, y)
                (Num.One, Num.Zero) => $op(1, 0)
                (Num.One, Num.One) => $op(1, 1)
                (Num.One, Num.Real(y)) => $op(1, y)
                (Num.Real(x), Num.Zero) => $op(x, 0)
                (Num.Real(x), Num.One) => $op(x, 1)
                (Num.Real(x), Num.Real(y)) => $op(x, y)
                _ => error("Cannot compare $lhs and $rhs")
            end
        end

        function Base.$op(lhs::Num.Type, rhs::Number)
            return $op(Number(lhs), rhs)
        end

        function Base.$op(lhs::Number, rhs::Num.Type)
            return $op(Number(lhs), rhs)
        end
    end
end
