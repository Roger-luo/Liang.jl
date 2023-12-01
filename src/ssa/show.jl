function get_slots(io::IO)
    haskey(io, :slots) && return io[:slots]
    return Dict{UInt64,String}()
end

function ssa2string(io::IO, ssa::Vector{UInt64})
    slots = get_slots(io)
    for (idx, x) in enumerate(ssa)
        print(io, "%", namify(slots, x))
        if idx < length(ssa)
            print(io, ", ")
        end
    end
    return nothing
end

function namify(slots::Dict{UInt64,String}, ssa::UInt64)::String
    haskey(slots, ssa) && return slots[ssa]
    return string(get(slots, ssa, ssa))
end

function Base.show(io::IO, x::OpCode)
    return print(io, x.name)
end

function Base.show(io::IO, b::Branch)
    slots = get_slots(io)
    is_return(b) && print(io, "return %", namify(slots, b.args[1]))
    if is_gotoifnot(b)
        print(io, "gotoifnot %", b.condition, " @", b.block, "(")
        ssa2string(io, b.args)
        print(io, ")")
    end

    return print(io, "goto @", b.block)
end

function Base.show(io::IO, x::SSAValue.Type)
    @match x begin
        SSAValue.Variable(id) => begin
            slots = get_slots(io)
            print(io, "%")
            print(io, namify(slots, id))
        end
        SSAValue.Constant(val) => print(io, val)
    end
end

function Base.show(io::IO, inst::Instruction)
    print(io, inst.op, "(", join(inst.args, ", "), ")")
    return inst.line > 0 && print(io, " #=", inst.line)
end

function Base.show(io::IO, bb::BasicBlockRef)
    tab(n) = print(io, " "^n)
    slots = get_slots(io)
    indent = get(io, :indent, 0)
    tab(indent)
    print(io, "@", bb.id, "(")
    ssa2string(io, bb.bb.args)
    println(io, "):")

    max_ndigits = ndigits(length(bb.ir.stmts))
    if !isempty(slots)
        max_ndigits = max(max_ndigits, maximum(ncodeunits.(string.(values(slots)))))
    end

    for (idx, (ssa, inst)) in enumerate(bb)
        tab(indent + 2)
        print(io, "%")
        name = namify(slots, ssa)
        tab(max_ndigits - ncodeunits(name))
        print(io, name, " = ")
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

function Base.show(io::IO, ir::IR)
    sub_io = IOContext(io, :indent => 2, :slots => ir.slots)
    for (idx, bb) in enumerate(ir)
        show(sub_io, bb)
        if idx < length(ir)
            println(io)
        end
    end
end
