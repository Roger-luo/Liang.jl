const UnitType = Quantity{
    Float64,SymbolicDimensions{DynamicQuantities.DEFAULT_DIM_BASE_TYPE}
}

@data Domain begin
    Natural
    Integer
    Rational
    Real
    Imag
    Complex
    Unknown
end

@derive Domain[PartialEq, Hash]

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
end

@derive Num[PartialEq, Hash]

"""
    Scalar

This is the basic scalar type. It supports pattern matching.
"""
@data Scalar begin
    # pattern semantics
    Variable(Variable.Type)

    # expression semantics
    Constant(Num.Type)

    # these are constant but usually
    # not treated as numerical constant
    # putting them here so they don't get
    # eval-ed when propagating constants
    Pi # Irrational{π}
    Euler # Irrational{e}

    """
    Planck constant
    """
    Hbar # Planck constant

    # some first-class functions
    Neg(Scalar)
    Conj(Scalar)
    Abs(Scalar)
    Exp(Scalar)
    Log(Scalar)
    Sqrt(Scalar)

    struct Add
        coeffs::Num.Type
        terms::ACSet{Scalar,Num.Type}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Mul
        coeffs::Num.Type
        terms::ACSet{Scalar,Num.Type}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Max
        terms::Set{Scalar}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Min
        terms::Set{Scalar}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Pow
        base::Scalar
        exp::Scalar
    end

    struct Div
        num::Scalar
        den::Scalar
    end

    struct JuliaCall
        mod::Module
        name::Symbol
        args::Vector{Scalar}
        hash::Hash.Cache = Hash.Cache()
    end

    struct RoutineCall
        name::Symbol
        args::Vector{Scalar}
        hash::Hash.Cache = Hash.Cache()
    end

    """
    Like variable, but points to an external
    Julia indexable object.
    """
    struct Subscript
        ref::Symbol
        indices::Vector{Index.Type}
        hash::Hash.Cache = Hash.Cache()
    end

    # derivative
    Partial(Scalar, Scalar)
    Derivative(Scalar, Scalar)

    """
    trace of an external expression
    """
    Tr(Any)

    """
    determinant of an external expression
    """
    Det(Any)

    Domain(Scalar, Domain.Type)
    Unit(Scalar, UnitType)
end

@derive Scalar[PartialEq, Hash, Tree]
