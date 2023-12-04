using LinearAlgebra
using Liang.Prelude
using Liang.SSA:
    OpCodeRegistry, IR, BasicBlock, Branch, Instruction, StmtRange, SSAValue, OpCode

opcode = OpCodeRegistry()
push!(opcode, Space)
push!(opcode, Basis)
push!(opcode, Index)
push!(opcode, Scalar)
push!(opcode, Op)
push!(opcode, Region)
push!(opcode, State)
push!(opcode, Tensor)
opcode

ir = IR(opcode)

t = kron(Op.X + comm(Op.Sx, Op.Y), Op.Z)'
tt = canonicalize(t)
