# some basic interface

Base.zero(::Type{Num.Type}) = Num.Zero
Base.one(::Type{Num.Type}) = Num.One
Base.zero(::Type{Scalar.Type}) = Scalar.Constant(Num.Zero)
Base.one(::Type{Scalar.Type}) = Scalar.Constant(Num.One)

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
