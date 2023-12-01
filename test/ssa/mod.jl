using Liang.Prelude
using Liang.SSA: OpCodeRegistry, IR, BasicBlock, Branch, Instruction, SSAValue, OpCode

opcodes = OpCodeRegistry()
ir = IR(
    opcodes,
    [
        Instruction(
            OpCode("Op.comm", 0x01), [SSAValue.Constant(Op.X), SSAValue.Variable(1)]
        ),
        Instruction(
            OpCode("Op.comm", 0x01), [SSAValue.Constant(Op.X), SSAValue.Variable(1)]
        ),
    ],
    [BasicBlock([1], StmtRange(1, 2), [Branch(0, 2, [1])])],
    Dict(),
)

goto(2)
ret(2)
