# TODO: Add some units here
@data Unit begin
    Some
    None
end

@data Domain begin
    Complex
    Real
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

    struct Fn
        name::Symbol
        args::Vector{Scalar}
        body::Scalar
    end

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
