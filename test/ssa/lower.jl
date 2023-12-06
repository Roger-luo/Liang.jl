using LinearAlgebra
using Liang.Prelude
using Liang.SSA:
    OpCodeRegistry, IR, BasicBlock, Branch, Instruction, StmtRange, SSAValue, OpCode

(kron(Op.I, Op.X) + kron(Op.X % Qubit, Op.Y % Qudit(3))) + Op.I

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
