@data Variable begin
    Wildcard
    Match(Symbol)
    SSA(UInt64)
    Slot(Symbol)
end

@derive Variable[PartialEq, Hash]

Base.convert(::Type{Variable.Type}, x::Symbol) = Variable.Slot(x)
Base.convert(::Type{Variable.Type}, x::UInt64) = Variable.SSA(x)

function Base.show(io::IO, v::Variable)
    @match v begin
        Wildcard => print(io, "_")
        Match(name) => print(io, "\$", name)
        SSA(id) => print(io, "%", id)
        Slot(name) => print(io, name)
    end
end
