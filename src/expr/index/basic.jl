Base.zero(::Type{Index.Type}) = Index.Constant(0)
Base.one(::Type{Index.Type}) = Index.Constant(1)

function Base.iszero(x::Index.Type)
    @match x begin
        Index.Constant(0) => true
        _ => false
    end
end

function Base.isone(x::Index.Type)
    @match x begin
        Index.Constant(1) => true
        _ => false
    end
end

function Base.isreal(x::Index.Type)
    return true
end
