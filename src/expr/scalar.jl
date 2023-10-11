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
    Complex(Float64, Float64)
    Irrational(Symbol)
end

@data Scalar begin
    Wildcard
    Literal(Num.Type)

    Variable(Symbol)
    Constant(Num.Type)

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
