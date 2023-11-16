# TODO: Add some units here
"""
expression for Unit
"""
@data Unit begin
    Some
    None
end

@derive Unit[PartialEq, Hash]

@data Domain begin
    Complex
    Real
end

@derive Domain[PartialEq, Hash]

# This is like MLIR IndexType
# depends on the Platform (32-bit or 64-bit)
"""
    Index

This is like MLIR IndexType, with basic support for arithmetic operations.
Unlike the general scalar expression, no simplification will be run on this expression.
It supports pattern matching.
"""
@data Index begin
    Wildcard
    Match(Symbol)

    """
    Constant index, e.g. 0, 1, 2, 3, ...
    """
    Constant(Int)

    struct Variable
        name::Symbol
        id::UInt64 = 0# SSA id
    end
    Add(Index, Index)
    Sub(Index, Index)
    Mul(Index, Index)
    Div(Index, Index) # int division, floor
    Rem(Index, Index) # remainder
    Pow(Index, Index)
    Neg(Index)
    Abs(Index)
end

@derive Index[PartialEq, Hash, Tree]

"""
    Num

This is the basic numeric type.
"""
@data Num begin
    Zero
    One
    Real(Float64)
    Imag(Float64)
    Complex(Float64, Float64)
    Pi # Irrational{π}
    Euler # Irrational{e}
end

@derive Num[PartialEq, Hash]

"""
    Scalar

This is the basic scalar type. It supports pattern matching.
"""
@data Scalar begin
    # pattern semantics
    Wildcard
    Match(Symbol) # Match a variable

    # expression semantics
    Constant(Num.Type)

    struct Variable
        name::Symbol
        id::UInt64 = 0# SSA id
    end

    # some first-class functions
    Neg(Scalar)
    Abs(Scalar)
    Exp(Scalar)
    Log(Scalar)
    Sqrt(Scalar)

    struct Sum
        coeffs::Num.Type
        terms::Dict{Scalar,Num.Type}
    end

    struct Prod
        coeffs::Num.Type
        terms::Dict{Scalar,Num.Type}
    end

    struct Pow
        base::Scalar
        exp::Scalar
    end

    struct Div
        num::Scalar
        den::Scalar
    end

    JuliaCall(Module, Symbol, Vector{Scalar})
    RoutineCall(Symbol, Vector{Scalar})

    # derivative
    Partial(Scalar, Scalar)
    Derivative(Scalar, Scalar)

    struct Annotate
        expr::Scalar
        domain::Domain.Type
        unit::Unit.Type
    end
end

@derive Scalar[PartialEq, Hash]
