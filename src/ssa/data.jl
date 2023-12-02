struct OpCode
    name::String
    arity::UInt64
end

"""
$TYPEDEF

The registry of all opcodes.

- `actions`: the corresponding action in the interpreter
    for evaluating the opcode using corresponding Julia
    functions.
- `variants`: the corresponding variant in the expression
- `names`: the name of the opcode
"""
struct OpCodeRegistry
    actions::Vector{Any}
    # corresponding variant in expr
    variants::Vector{Any}
    names::Vector{String}
    hash::Dict{UInt64,Int64} # hash(variant) => index
end

OpCodeRegistry() = OpCodeRegistry([], [], String[], Dict{UInt64,Int64}())

function Base.setindex!(reg::OpCodeRegistry, action, variant)
    h = hash(variant)
    if haskey(reg.hash, h)
        idx = reg.hash[h]
        reg.actions[idx] = action
    else
        push!(reg.actions, action)
        push!(reg.variants, variant)
        push!(reg.names, string(variant))
        reg.hash[h] = length(reg.actions)
    end
    return reg
end

function Base.getindex(reg::OpCodeRegistry, opcode::UInt64)
    return OpCode(reg.names[opcode], opcode)
end

function Base.getindex(reg::OpCodeRegistry, variant)
    opcode = get(reg.hash, hash(variant)) do
        error("no such opcode: $variant")
    end
    return OpCode(reg.names[opcode], opcode)
end

function Base.getindex(reg::OpCodeRegistry, opcode::Int64)
    return reg.actions[UInt64(opcode)]
end

@data SSAValue begin
    Variable(UInt64)
    # constant expression
    # not necessarily a constant value
    # can also be e.g Op.X + Op.Y
    Constant(Any)
end

struct Instruction
    op::OpCode
    args::Vector{SSAValue.Type}
    line::UInt64
end

Instruction(op::OpCode, args::Vector{SSAValue.Type}) = Instruction(op, args, 0)

struct Branch
    condition::UInt64
    block::UInt64
    args::Vector{UInt64}
end

is_return(b::Branch) = b.block == 0 && length(b.args) == 1
is_gotoifnot(b::Branch) = b.condition > 0

struct StmtRange
    start::UInt64
    stop::UInt64
end

Base.length(r::StmtRange) = r.stop - r.start + 1
Base.eltype(r::StmtRange) = UInt64
Base.getindex(r::StmtRange, i::UInt64) = r.start + i - 1
Base.getindex(r::StmtRange, i::Int) = r[UInt64(i)]
function Base.iterate(r::StmtRange, st::UInt64=r.start)
    st > r.stop && return nothing
    return st, st + 1
end

struct BasicBlock
    args::Vector{UInt64}
    stmts::StmtRange
    branches::Vector{Branch}
end

struct IR
    opcode::OpCodeRegistry
    stmts::Vector{Instruction}
    blocks::Vector{BasicBlock}
    # some SSAValue has name
    slots::Dict{UInt64,String}
end

struct BasicBlockRef
    id::UInt64
    bb::BasicBlock
    ir::IR
end

Base.getindex(ir::IR, idx::Int) = BasicBlockRef(idx, ir.blocks[idx], ir)
Base.length(ir::IR) = length(ir.blocks)
Base.eltype(ir::IR) = BasicBlockRef
function Base.iterate(ir::IR, st::Int=1)
    st > length(ir) && return nothing
    return ir[st], st + 1
end

Base.eltype(bb::BasicBlockRef) = Pair{UInt64,Instruction}
Base.length(bb::BasicBlockRef) = length(bb.bb.stmts)

function Base.getindex(bb::BasicBlockRef, idx::Int)
    ssa = bb.bb.stmts[idx]
    return ssa => bb.ir.stmts[ssa]
end

function Base.iterate(bb::BasicBlockRef, st::Int=1)
    st > length(bb) && return nothing
    return bb[st], st + 1
end
