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
end

@data SSAValue begin
    Variable(UInt64)
    # constant expression
    # not necessarily a constant value
    # can also be e.g Op.X + Op.Y
    Constant(Any)
end

struct Instruction
    op::UInt64
    args::Vector{SSAValue.Type}
    line::UInt64
end

struct Branch
    condition::UInt64
    block::UInt64
    args::Vector{UInt64}
end

struct StmtRange
    start::UInt64
    stop::UInt64
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
    slots::Dict{UInt64,Symbol}
end
