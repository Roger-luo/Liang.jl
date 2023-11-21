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

@data Op begin
    Wildcard
    Match(Symbol) # Match a variable

    # these constants
    # are just predefined for convenience
    I # Identity
    X
    Y
    Z

    """
    Spin Pauli operator `Sx` with `d`-dimensional spin.
    """
    Sx

    """
    Spin Pauli operator `Sy` with `d`-dimensional spin.
    """
    Sy

    """
    Spin Pauli operator `Sz` with `d`-dimensional spin.
    """
    Sz

    S
    H
    T
    SWAP

    Constant(PrimitiveOp.Type)
    struct Variable
        name::Symbol
        id::UInt64 = 0# SSA id
    end

    struct Add
        coeffs::Scalar.Type # Identity
        terms::Dict{Op,Scalar.Type}
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
    Subscript(Op, Vector{Index.Type})

    struct Sum
        region
        term::Op
    end

    struct Prod
        region
        term::Op
    end

    # primitive operations
    Exp(Op)
    Log(Op)
    Tr(Op)
    Det(Op)
    Inv(Op)
    Sqrt(Op)
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
