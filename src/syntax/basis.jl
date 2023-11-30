function Base.:(*)(lhs::Space.Type, rhs::Space.Type)
    return Space.Product(lhs, rhs)
end

function Base.:(^)(base::Space.Type, n::Int)
    n > 0 || error("exponent must be positive")
    return Space.Pow(base, n)
end

function Base.:(*)(lhs::Basis, rhs::Basis)
    return Basis(kron(lhs.op, rhs.op), lhs.space * rhs.space)
end

function Base.:(^)(base::Basis, n::Int)
    n > 0 || error("exponent must be positive")
    return Basis(Op.KronPow(base.op, n), base.space^n)
end

function Base.getindex(space::Space.Type, indices)
    length(indices) <= n_levels(space) || error("index out of range")
    return Space.Subspace(space, collect(Int, indices))
end

const Qubit = Basis(Op.Z, Space.Qubit)

function Qudit(d::Int)
    return Basis(Op.Z, Space.Qudit(d))
end
