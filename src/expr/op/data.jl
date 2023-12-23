# NOTE: we don't intend to handle
# large operators with OpValue, large
# operators should be computed with:
#
# 1. compiled kernels
# 2. symbolic expression
#
# OpValue is only for small operators, and
# other cheap exact evaluation.

@data OpValue begin
    Pauli(Vector{UInt8})

    # we need a constant sparse pattern
    # if it's non-constant, use the Op
    # expression.
    #
    # weights can be Scalar.Type, but must
    # be concrete expression (no variables)
    # this is mainly because we want to preserve
    # certain structure of the expression so
    # expectation value of the operator can be expressive, e.g
    # exp(-im*theta) as entries.
    Perm(Int, PermMatrix{Scalar.Type, <:Integer})
    Dense(Int, Matrix{Scalar.Type})
    Sparse(Int, SparseMatrixCSC{Scalar.Type})
end

@derive OpValue[PartialEq, Hash]

TWOLEVEL_NOTE = """
!!! note
        This operator expects a basis of 2-level space.
"""

@data Op begin
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

    Constant(OpValue.Type)
    Variable(Variable.Type)

    struct Add
        terms::ACSet{Op,Scalar.Type}
        hash::Hash.Cache = Hash.Cache()
    end

    Mul(Op, Op)
    # TimeOrdered(Op,Symbol)
    Kron(Op, Op)

    struct Comm
        base::Op
        op::Op
        pow::Index.Type = Index.Constant(1)
    end

    struct AComm
        base::Op
        op::Op
        pow::Index.Type = Index.Constant(1)
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

    """
    Mark the operator expression is ordered by
    a corresponding time variable.
    """
    TimeOrdered(Op, Variable.Type)

    struct Subscript
        op::Op
        indices::Vector{Index.Type}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Sum
        region::Region.Type
        indices::Vector{Symbol}
        term::Op
        hash::Hash.Cache = Hash.Cache()
    end

    struct Prod
        region::Region.Type
        indices::Vector{Symbol}
        term::Op
        hash::Hash.Cache = Hash.Cache()
    end

    # primitive operations
    Exp(Op)
    Log(Op)
    Inv(Op)
    Sqrt(Op)
    Conj(Op)
    Transpose(Op)

    struct Outer
        lhs::State.Type
        rhs::State.Type
    end

    struct RoutineCall # return must be Op
        routine::Routine{Op.Type}
        args::Vector{Any}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Annotate
        expr::Op
        basis::Basis
    end
end

@derive Op[PartialEq, Hash, Tree]

Base.convert(::Type{Op.Type}, op::OpValue.Type) = Op.Constant(op)
