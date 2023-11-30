for op in (:<, :<=, :>, :>=, :isless)
    @eval function Base.$op(lhs::Index.Type, rhs::Index.Type)
        @match (lhs, rhs) begin
            # TODO: run canonicalize on lhs and rhs
            (Index.Constant(x), Index.Constant(y)) => $op(x, y)
            _ => error("Cannot compare $lhs and $rhs")
        end
    end
end # for op in (:<, :<=, :>, :>=, :isless)
