function Base.show(io::IO, x::OpCode)
    return print(io, x.name)
end

function Base.show(io::IO, b::Branch)
    is_return(b) && print(io, "return %", b.args[1])
    if is_gotoifnot(b)
        print(io, "gotoifnot %", b.condition, " @", b.block, "(")
        join(io, map(x -> string("%", x), b.args), ", ")
        print(io, ")")
    end

    return print(io, "goto @", b.block)
end

function Base.show(io::IO, x::SSAValue.Type)
    @match x begin
        SSAValue.Variable(id) => print(io, "%", id)
        SSAValue.Constant(val) => print(io, val)
    end
end

function Base.show(io::IO, inst::Instruction)
    print(io, inst.op, "(", join(inst.args, ", "), ")")
    return inst.line > 0 && print(io, " #=", inst.line)
end

function Base.show(io::IO, bb::BasicBlockRef)
    tab(n) = print(io, " "^n)
    indent = get(io, :indent, 0)
    tab(indent)
    print(io, "@", bb.id, "(")
    ssa2string(io, bb.bb.args)
    println(io, "):")

    max_ndigits = ndigits(length(bb.ir.stmts))
    for (idx, (ssa, inst)) in enumerate(bb)
        tab(indent + 2)
        print(io, "%")
        tab(max_ndigits - ndigits(ssa))
        print(io, ssa, " = ")
        show(io, inst)
        if !isempty(bb.bb.branches) || idx < length(bb.ir.stmts)
            println(io)
        end
    end

    for (idx, branch) in enumerate(bb.bb.branches)
        tab(indent + 2)
        show(io, branch)
        if idx < length(bb.bb.branches)
            println(io)
        end
    end
end

function ssa2string(io::IO, ssa::Vector{UInt64})
    return join(io, map(x -> string("%", x), ssa), ", ")
end

function Base.show(io::IO, ir::IR)
    for (idx, bb) in enumerate(ir)
        show(IOContext(io, :indent => 2), bb)
        if idx < length(ir)
            println(io)
        end
    end
end
