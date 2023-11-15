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
        Num.Pi => true
        Num.Euler => true
        _ => false
    end
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
        _ => false
    end
end
