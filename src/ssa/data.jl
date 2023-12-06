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
    # corresponding variant in expr
    variants::Vector{Any}
    names::Vector{String}
    opcode::Dict{Any,UInt64} # variant => index
end

OpCodeRegistry() = OpCodeRegistry([], String[], Dict{UInt64,UInt64}())
function Base.push!(reg::OpCodeRegistry, variant)
    haskey(reg.opcode, variant) && return reg
    push!(reg.variants, variant)
    push!(reg.names, string(variant))
    reg.opcode[variant] = UInt64(length(reg.variants))
    return reg
end

function Base.push!(reg::OpCodeRegistry, mod::Module)
    (isdefined(mod, :Type) && is_data_type(mod.Type)) ||
        error("expect a type defined by @data")
    for each in variants(mod.Type)
        push!(reg, each)
    end
    return reg
end

function Base.getindex(reg::OpCodeRegistry, opcode::UInt64)
    return OpCode(reg.names[opcode], opcode)
end

function Base.getindex(reg::OpCodeRegistry, variant)
    type = is_singleton(variant) ? variant_type(variant) : variant
    opcode = get(reg.opcode, type) do
        error("no such opcode: $type")
    end
    return OpCode(reg.names[opcode], opcode)
end

function Base.getindex(reg::OpCodeRegistry, opcode::Int64)
    return reg[UInt64(opcode)]
end

@data SSAValue begin
    Wildcard
    Match(Symbol)
    Variable(UInt64)
    # constant expression
    # not necessarily a constant value
    # can also be e.g Op.X + Op.Y
    Constant(Any)
end

struct Instruction
    op::OpCode
    args::Vector{SSAValue.Type}
end

struct Branch
    condition::Int64
    block::UInt64
    args::Vector{Int64}
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
    args::Vector{Int64}
    stmts::StmtRange
    branches::Vector{Branch}
end

struct IR
    stmts::Vector{Instruction}
    blocks::Vector{BasicBlock}
    # the registry of all opcodes
    opcode::OpCodeRegistry
    # some SSAValue has name
    slots::Dict{UInt64,Variable.Type}
end

function IR(
    opcode::OpCodeRegistry, slots::Dict{UInt64,Variable.Type}=Dict{UInt64,Variable.Type}()
)
    return IR(Instruction[], BasicBlock[], opcode, slots)
end

struct NewBasicBlock
    ir::IR
    args::Vector{UInt64}
    stmts::Vector{Instruction}
    branches::Vector{Branch}
end

function NewBasicBlock(ir::IR, args::Vector{UInt64}=UInt64[])
    return NewBasicBlock(ir, args, Instruction[], Branch[])
end

function inst!(bb::NewBasicBlock, variant, args::Vector{SSAValue.Type})
    push!(bb.stmts, Instruction(bb.ir.opcode[variant], args))
    return bb
end

function branch!(bb::NewBasicBlock, condition::UInt64, block::UInt64, args::Vector{UInt64})
    push!(bb.branches, Branch(condition, block, args))
    return bb
end

function branch!(bb::NewBasicBlock, block::UInt64, args::Vector{UInt64})
    push!(bb.branches, Branch(0, block, args))
    return bb
end

function ret!(bb::NewBasicBlock, arg::UInt64)
    branch!(bb, 0, [arg])
    return bb
end

function finish!(bb::NewBasicBlock)
    push!(
        bb.ir.blocks,
        BasicBlock(
            bb.args,
            StmtRange(length(bb.ir.stmts) + 1, length(bb.ir.stmts) + length(bb.stmts)),
            bb.branches,
        ),
    )
    append!(bb.ir.stmts, bb.stmts)
    return bb.ir
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
