@data SSAValue begin
    Value(UInt64)
    Argument(UInt64)
    Extern(Any)
    Wildcard
    Match(UInt64)
end

struct OpCode
    arity::UInt64
    name::String
end

struct Branch
    condition::SSAValue.Type
    block::UInt64
    args::Vector{SSAValue.Type}
end

struct Instruction
    opcode::OpCode
    args::Vector{SSAValue.Type}
end

struct BasicBlock
    args::Vector{UInt64}
    stmts::Vector{Instruction}
    branches::Vector{Branch}
end

struct IR
    defs::Vector{Tuple{Int64,Int64}}
    blocks::Vector{BasicBlock}
end
