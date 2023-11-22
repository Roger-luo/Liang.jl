# some basic interface

function Base.iszero(x::Num.Type)
    @match x begin
        Num.Zero => true
        _ => false
    end
end

function Base.isone(x::Num.Type)
    @match x begin
        Num.One => true
        _ => false
    end
end

function Base.isreal(x::Num.Type)
    @match x begin
        Num.Zero => true
        Num.One => true
        Num.Real(_) => true
        _ => false
    end
end

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

function Base.iszero(x::Scalar.Type)
    @match x begin
        Scalar.Constant(x) => iszero(x)
        _ => false
    end
end

function Base.isone(x::Scalar.Type)
    @match x begin
        Scalar.Constant(x) => isone(x)
        _ => false
    end
end

function Base.isreal(x::Scalar.Type)
    @match x begin
        Scalar.Constant(x) => isreal(x)
        Scalar.Pi => true
        Scalar.Euler => true
        Scalar.Hbar => true
        _ => false
    end
end
