@syntax function Base.:(+)(lhs::Op.Type, rhs::Op.Type)
    # NOTE: unlike the scalar case, we don't calculate
    # constant in case it's too slow.
    if lhs == rhs
        return Op.Add(Dict(lhs => 2))
    else
        return Op.Add(Dict(lhs => 1, rhs => 1))
    end
end

@syntax function Base.:(+)(lhs::Op.Type, rhs::Union{Number,Scalar.Type})
    return Op.Add(Dict(lhs => 1)) + rhs * Op.I
end

@syntax function Base.:(+)(lhs::Union{Number,Scalar.Type}, rhs::Op.Type)
    return rhs + lhs
end

@syntax function Base.:(-)(op::Op.Type)
    return Op.Add(Dict(op => -1))
end

@syntax function Base.:(-)(lhs::Op.Type, rhs::Op.Type)
    lhs == rhs && return Op.Zero
    return Op.Add(Dict(lhs => 1, rhs => -1))
end

@syntax function Base.:(-)(lhs::Op.Type, rhs::Union{Number,Scalar.Type})
    return Op.Add(Dict(lhs => 1)) - rhs * Op.I
end

@syntax function Base.:(-)(lhs::Union{Number,Scalar.Type}, rhs::Op.Type)
    return -rhs + lhs
end

@syntax function Base.:(*)(lhs::Op.Type, rhs::Op.Type)
    return Op.Mul(lhs, rhs)
end

@syntax function Base.:(*)(lhs::Op.Type, rhs::Union{Number,Scalar.Type})
    return Op.Add(Dict(lhs => rhs))
end

@syntax function Base.:(*)(lhs::Union{Number,Scalar.Type}, rhs::Op.Type)
    return rhs * lhs
end

@syntax function Base.:(/)(lhs::Op.Type, rhs::Op.Type)
    return lhs * Op.Inv(rhs)
end

@syntax function Base.:(\)(lhs::Op.Type, rhs::Op.Type)
    return Op.Inv(lhs) * rhs
end

@syntax function Base.:(^)(lhs::Op.Type, rhs::Scalar.Type)
    return Op.Pow(lhs, rhs)
end

@syntax function Base.:(^)(lhs::Op.Type, rhs::Number)
    return Op.Pow(lhs, Scalar.Constant(rhs))
end

@syntax function Base.kron(lhs::Op.Type, rhs::Op.Type)
    return Op.Kron(lhs, rhs)
end

@syntax function Base.kron(x1::Op.Type, x2::Op.Type, xs::Op.Type...)
    return reduce(kron, (x1, x2, xs...))
end

@syntax function comm(base::Op.Type, op::Op.Type)
    return comm(base, op, 1)
end

@syntax function comm(base::Op.Type, op::Op.Type, pow::Int)
    return comm(base, op, Index.Constant(pow))
end

@syntax function comm(base::Op.Type, op::Op.Type, pow::Index.Type)
    return Op.Comm(base, op, pow)
end

@syntax function acomm(base::Op.Type, op::Op.Type)
    return acomm(base, op, 1)
end

@syntax function acomm(base::Op.Type, op::Op.Type, pow::Int)
    return acomm(base, op, Index.Constant(pow))
end

@syntax function acomm(base::Op.Type, op::Op.Type, pow::Index.Type)
    return Op.AComm(base, op, pow)
end

@syntax Base.conj(op::Op.Type) = Op.Conj(op)
@syntax Base.adjoint(op::Op.Type) = Op.Adjoint(op)

@syntax function Base.getindex(op::Op.Type, subscripts::Union{Int,Symbol,Index.Type}...)
    return Op.Subscript(; op, indices=collect(Index.Type, subscripts))
end

@syntax function Base.sum(region, term::Pair{Vector{Index.Type},Op.Type})
    return Op.Sum(region, term.first, term.second)
end

@syntax function Base.prod(region, term::Pair{Vector{Index.Type},Op.Type})
    return Op.Prod(region, term.first, term.second)
end

@syntax function Base.exp(op::Op.Type)
    return Op.Exp(op)
end

@syntax function Base.log(op::Op.Type)
    return Op.Log(op)
end

@syntax function LinearAlgebra.tr(op::Op.Type)
    return Scalar.Tr(canonicalize(op))
end

@syntax function LinearAlgebra.det(op::Op.Type)
    return Scalar.Det(canonicalize(op))
end

@syntax function Base.inv(op::Op.Type)
    return Op.Inv(op)
end

@syntax function Base.sqrt(op::Op.Type)
    return Op.Sqrt(op)
end

@syntax function Base.transpose(op::Op.Type)
    return Op.Transpose(op)
end

@syntax function Base.rem(op::Op.Type, basis::Basis)
    return Op.Annotate(op, basis)
end

@syntax function outer(lhs::State.Type, rhs::State.Type)
    return Op.Outer(lhs, rhs)
end

struct EigenDecomp
    op::Op.Type
end

function Base.show(io::IO, x::EigenDecomp)
    print(io, "eigen(")
    Tree.Print.inline(io, x.op)
    return print(io, ")")
end

@syntax function Base.getindex(eig::EigenDecomp, idx::Int)
    return State.Eigen(eig.op, idx)
end

function LinearAlgebra.eigen(op::Op.Type)
    return EigenDecomp(op)
end
