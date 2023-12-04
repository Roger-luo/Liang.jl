using Liang.Prelude
using Liang.SSA:
    OpCodeRegistry, IR, BasicBlock, Branch, Instruction, StmtRange, SSAValue, OpCode

opcodes = OpCodeRegistry()
push!(opcodes, Op.Comm)
opcodes[Op.Comm]

ir = IR(
    [
        Instruction(opcodes[Op.Comm], [SSAValue.Constant(Op.X), SSAValue.Variable(1)]),
        Instruction(opcodes[Op.Comm], [SSAValue.Constant(Op.X), SSAValue.Variable(1)]),
    ],
    [BasicBlock([1], StmtRange(1, 2), [Branch(0, 2, [1])])],
    opcodes,
    Dict(2 => "x"),
)

ir
