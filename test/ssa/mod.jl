using Liang.Prelude
using Liang.SSA:
    OpCodeRegistry, IR, BasicBlock, Branch, Instruction, StmtRange, SSAValue, OpCode

opcodes = OpCodeRegistry()

opcodes[Op.Comm] = function (group, op, exp)
    return print("Op.comm(", group, ", ", op, ", ", exp, ")")
end
opcodes

ir = IR(
    opcodes,
    [
        Instruction(opcodes[Op.Comm], [SSAValue.Constant(Op.X), SSAValue.Variable(1)]),
        Instruction(opcodes[Op.Comm], [SSAValue.Constant(Op.X), SSAValue.Variable(1)]),
    ],
    [BasicBlock([1], StmtRange(1, 2), [Branch(0, 2, [1])])],
    Dict(2 => "x"),
)

ir
