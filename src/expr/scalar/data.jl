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

    Inf

    """
    Constant index, e.g. 0, 1, 2, 3, ...
    """
    Constant(Int)

    """
    Variable index, e.g. i, j, k, ...
    """
    struct Variable
        name::Symbol
        id::UInt64 = 0# SSA id
    end

    """
    Add two indices
    """
    Add(Index, Index)

    """
    Subtract two indices
    """
    Sub(Index, Index)

    """
    Multiply two indices
    """
    Mul(Index, Index)

    """
    Divide two indices
    """
    Div(Index, Index) # int division, floor

    """
    Modular division
    """
    Rem(Index, Index) # remainder

    """
    Power of two indices
    """
    Pow(Index, Index)

    """
    Maximum of two indices
    """
    Max(Index, Index)

    """
    Minimum of two indices
    """
    Min(Index, Index)

    """
    Negate an index
    """
    Neg(Index)

    """
    Absolute value of an index
    """
    Abs(Index)

    """
    require evaluation on `n_sites` of variable from other expression
    """
    struct NSites
        name::Symbol
        id::UInt64 = 0# SSA id
    end

    """
    assert two indices are equal
    """
    struct AssertEqual
        lhs::Index
        rhs::Index
        msg::String
    end
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

    struct Variable
        name::Symbol
        id::UInt64 = 0# SSA id
    end

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
