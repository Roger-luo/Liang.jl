# TODO: Add some units here
@data Unit begin
    Some
    None
end

@data Domain begin
    Complex
    Real
end

# This is like MLIR IndexType
# depends on the Platform (32-bit or 64-bit)
@data Index begin
    Wildcard
    Match(Symbol)

    Constant(Int)
    Variable(Symbol)
    Add(Index, Index)
    Sub(Index, Index)
    Mul(Index, Index)
    Div(Index, Index) # int division, floor
    Rem(Index, Index) # remainder
    Pow(Index, Index)
    Neg(Index)
    Abs(Index)
end

@data Num begin
    Real(Float64)
    Imag(Float64)
    Complex(Float64, Float64)
    Pi # Irrational{π}
    Euler # Irrational{e}
end

@data Scalar begin
    # pattern semantics
    Wildcard
    Match(Symbol) # Match a variable

    # expression semantics
    Constant(Num.Type)
    Variable(Symbol)

    Neg(Scalar)
    Abs(Scalar)
    Call(Symbol, Vector{Scalar})

    struct Sum
        coeffs::Num.Type
        terms::Dict{Scalar, Num.Type}
    end

    struct Prod
        coeffs::Num.Type
        terms::Dict{Scalar, Num.Type}
    end

    struct Pow
        base::Scalar
        exp::Scalar
    end

    struct Div
        num::Scalar
        den::Scalar
    end

    struct Annotate
        expr::Scalar
        domain::Domain.Type
        unit::Unit.Type
    end
end
