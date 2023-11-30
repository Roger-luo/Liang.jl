Base.convert(::Type{Index.Type}, x::Int) = Index.Constant(x)
Base.convert(::Type{Index.Type}, x::Symbol) = Index.Variable(x)

# backwards conversion
function Base.convert(::Type{Int}, x::Index.Type)
    if isa_variant(x, Index.Constant)
        return x.:1
    else
        error("Expect a constant index, got $x")
    end
end

function Base.convert(::Type{Symbol}, x::Index.Type)
    @match x begin
        Index.Variable(Variable.Slot(name)) => return name
        Index.Variable(Variable.Match(name)) => return name
        _ => error("Expect a variable index, got $x")
    end
end
