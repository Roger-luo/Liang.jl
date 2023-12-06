function lower2ssa!(ir::IR, op::Index.Type)
    expr_vars = vars(op)
    for (idx, v) in enumerate(expr_vars)
        ir.slots[idx] = v
    end

    return NewBasicBlock(ir; args=UInt64[1:length(ir)])
    # @match op begin
    # end
end
