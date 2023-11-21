function Base.:(+)(lhs::Op.Type, rhs::Op.Type)
    # NOTE: unlike the scalar case, we don't calculate
    # constant in case it's too slow.
    if lhs == rhs
        return Op.Add(0, Dict(lhs => 2))
    else
        return Op.Add(0, Dict(lhs => 1, rhs => 1))
    end
end

function Base.:(+)(lhs::Op.Type, rhs::Union{Number,Scalar.Type})
    return Op.Add(rhs, Dict(lhs => 1))
end

function Base.:(+)(lhs::Union{Number,Scalar.Type}, rhs::Op.Type)
    return Op.Add(lhs, Dict(rhs => 1))
end

function Base.:(-)(lhs::Op.Type, rhs::Op.Type)
    return Op.Add(0, Dict(lhs => 1, rhs => -1))
end

function Base.:(-)(lhs::Op.Type, rhs::Union{Number,Scalar.Type})
    return Op.Add(-rhs, Dict(lhs => 1))
end

function Base.:(-)(lhs::Union{Number,Scalar.Type}, rhs::Op.Type)
    return Op.Add(lhs, Dict(rhs => -1))
end

function Base.:(*)(lhs::Op.Type, rhs::Op.Type)
    return Op.Mul(lhs, rhs)
end

function Base.:(*)(lhs::Op.Type, rhs::Union{Number,Scalar.Type})
    return Op.Add(0, Dict(lhs => rhs))
end

function Base.:(*)(lhs::Union{Number,Scalar.Type}, rhs::Op.Type)
    return Op.Add(0, Dict(rhs => lhs))
end

function Base.:(/)(lhs::Op.Type, rhs::Op.Type)
    return lhs * Op.Inv(rhs)
end

function Base.:(\)(lhs::Op.Type, rhs::Op.Type)
    return Op.Inv(lhs) * rhs
end

function Base.:(^)(lhs::Op.Type, rhs::Scalar.Type)
    return Op.Pow(lhs, rhs)
end

function Base.:(^)(lhs::Op.Type, rhs::Number)
    return Op.Pow(lhs, Scalar.Constant(rhs))
end

function Base.kron(lhs::Op.Type, rhs::Op.Type)
    return Op.Kron(lhs, rhs)
end

function Base.kron(x1::Op.Type, x2::Op.Type, xs::Op.Type...)
    return reduce(kron, (x1, x2, xs...))
end

function comm(base::Op.Type, op::Op.Type)
    return comm(base, op, 1)
end

function comm(base::Op.Type, op::Op.Type, pow::Int)
    return comm(base, op, Scalar.Constant(pow))
end

function comm(base::Op.Type, op::Op.Type, pow::Index.Type)
    return Op.Comm(base, op, pow)
end

function acomm(base::Op.Type, op::Op.Type)
    return acomm(base, op, 1)
end

function acomm(base::Op.Type, op::Op.Type, pow::Int)
    return acomm(base, op, Scalar.Constant(pow))
end

function acomm(base::Op.Type, op::Op.Type, pow::Index.Type)
    return Op.AComm(base, op, pow)
end

function Base.adjoint(op::Op.Type)
    return Op.Adjoint(op)
end

function Base.getindex(op::Op.Type, subscripts::Union{Int,Symbol,Index.Type}...)
    return Op.Subscript(op, collect(Index.Type, subscripts))
end

function Base.sum(region, op::Op.Type)
    return Op.Sum(region, op)
end

function Base.prod(region, op::Op.Type)
    return Op.Prod(region, op)
end

function Base.exp(op::Op.Type)
    return Op.Exp(op)
end

function Base.log(op::Op.Type)
    return Op.Log(op)
end

function LinearAlgebra.tr(op::Op.Type)
    return Op.Tr(op)
end

function LinearAlgebra.det(op::Op.Type)
    return Op.Det(op)
end

function Base.inv(op::Op.Type)
    return Op.Inv(op)
end

function Base.sqrt(op::Op.Type)
    return Op.Sqrt(op)
end

function Base.transpose(op::Op.Type)
    return Op.Transpose(op)
end

function Base.rem(op::Op.Type, basis::Basis)
    return Op.Annotate(op, basis)
end
