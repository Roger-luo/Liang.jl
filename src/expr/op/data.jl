@data PrimitiveOp begin
    Pauli(Vector{UInt8})

    struct Perm
        nsites::Int
        perm::Vector{UInt8}
        weights::Vector{Scalar.Type}
    end

    Matrix(Matrix{ComplexF64})
end

@data Op begin
    Wildcard
    Match(Symbol) # Match a variable

    I # Identity
    Constant(PrimitiveOp.Type)
    Variable(Symbol)

    struct Add
        coeffs::Scalar.Type # Identity
        terms::Dict{Op, Scalar.Type}
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
