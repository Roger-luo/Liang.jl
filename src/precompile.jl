using PrecompileTools

@setup_workload begin
    using Liang.Prelude
    @compile_workload begin
        redirect_stdout(devnull) do
            Tree.Print.inline(canonicalize(comm(Op.X, comm(Op.X, Op.Y), 2)))
            Tree.Print.inline(canonicalize(acomm(Op.X, acomm(Op.X, Op.Y), 2)))
            Tree.Print.text(canonicalize(Op.X^2 * Op.X^3))
            Tree.Print.text(canonicalize(acomm(Op.X, acomm(Op.X, Op.Y), 2)))
            Tree.Print.text(canonicalize(comm(Op.X, Op.Y, 2)'))
            Tree.Print.text(canonicalize(2.0 * comm(Op.X, Op.Y, 3)'))
        end
    end
end
