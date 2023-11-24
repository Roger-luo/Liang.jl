@data PrimitiveOp begin
    Pauli(Vector{UInt8})

    struct Perm
        nsites::Int
        perm::Vector{UInt8}
        weights::Vector{Scalar.Type}
    end

    Matrix(Matrix{ComplexF64})
end

@derive PrimitiveOp[PartialEq, Hash]

TWOLEVEL_NOTE = """
!!! note
        This operator expects a basis of 2-level space.
"""

@data Op begin
    Wildcard
    Match(Symbol) # Match a variable

    # these constants
    # are just predefined for convenience
    Zero # 0
    I # Identity

    """
    Pauli operator `X` with `d`-dimensional spin.
    """
    X

    """
    Pauli operator `Y` with `d`-dimensional spin.
    """
    Y

    """
    Pauli operator `Z` with `d`-dimensional spin.
    """
    Z

    """
    Spin operator `Sx` with `d`-dimensional spin.

    ```math
    Sx = \\frac{ħ}{2} X
    ```
    """
    Sx

    """
    Spin operator `Sy` with `d`-dimensional spin.

    ```math
    Sy = \\frac{ħ}{2} Y
    ```
    """
    Sy

    """
    Spin operator `Sz` with `d`-dimensional spin.

    ```math
    Sz = \\frac{ħ}{2} Z
    ```
    """
    Sz

    """
    Hadamard operator `H` on 2-level system.

    $TWOLEVEL_NOTE
    """
    H

    """
    T-gate operator `T` on 2-level system.

    $TWOLEVEL_NOTE
    """
    T

    Constant(PrimitiveOp.Type)
    struct Variable
        name::Symbol
        id::UInt64 = 0# SSA id
    end

    struct Add
        terms::Dict{Op,Scalar.Type}
        hash::Hash.Cache = Hash.Cache()
    end

    Mul(Op, Op)
    Kron(Op, Op)

    struct Comm
        base::Op
        op::Op
        pow::Index.Type
    end

    struct AComm
        base::Op
        op::Op
        pow::Index.Type
    end

    struct Pow
        base::Op
        exp::Scalar.Type
    end

    struct KronPow
        base::Op
        exp::Index.Type
    end

    Adjoint(Op)

    struct Subscript
        op::Op
        indices::Vector{Index.Type}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Sum
        region
        indices::Vector{Index.Type}
        term::Op
        hash::Hash.Cache = Hash.Cache()
    end

    struct Prod
        region
        indices::Vector{Index.Type}
        term::Op
        hash::Hash.Cache = Hash.Cache()
    end

    # primitive operations
    Exp(Op)
    Log(Op)
    Tr(Op)
    Det(Op)
    Inv(Op)
    Sqrt(Op)
    Conj(Op)
    Transpose(Op)

    struct Outer
        lhs::State.Type
        rhs::State.Type
    end

    struct Annotate
        expr::Op
        basis::Basis
    end
end

@derive Op[PartialEq, Hash]

Base.convert(::Type{Op.Type}, op::PrimitiveOp.Type) = Op.Constant(op)
