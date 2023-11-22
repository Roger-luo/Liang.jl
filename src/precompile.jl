using PrecompileTools

@setup_workload begin
    using Liang.Expression.Prelude
    @compile_workload begin
        Tree.inline_print(canonicalize(comm(Op.X, comm(Op.X, Op.Y), 2)))
        Tree.inline_print(canonicalize(acomm(Op.X, acomm(Op.X, Op.Y), 2)))
        Tree.text_print(canonicalize(Op.X^2 * Op.X^3))
        Tree.text_print(canonicalize(acomm(Op.X, acomm(Op.X, Op.Y), 2)))
        Tree.text_print(canonicalize(comm(Op.X, Op.Y, 2)'))
        Tree.text_print(canonicalize(2.0 * comm(Op.X, Op.Y, 3)'))
    end
end
