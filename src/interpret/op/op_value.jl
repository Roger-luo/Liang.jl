

pauli(a::UInt8)::PermMatrix = @match a begin
    0x00 => IMatrix(2)
    0x01 => PermMatrix([2, 1],[1, 1])
    0x02 => PermMatrix([2, 1],[1im, -1im])
    0x03 => PermMatrix([1, 2],[-1, 1])
end

function mat(OpValue.Type)::AbstractMatrix
    @match mat begin
        OpValue.Perm(nrows, mat) => mat
        OpValue.Dense(nrows, mat) => mat
        OpValue.Sparse(nrows, mat) => mat
        OpValue.Identity(nrows) => IMatrix(nrows)
        OpValue.Pauli(opstr) => begin
            mat = pauli(first(opstr))
            for op in opstr[2:end]
                mat = kron(mat, pauli(op))
            end
            mat
        end
end


function Base.convert(::Type{OpValue.Type}, mat::AbstractMatrix)::OpValue.Type
    nrow, ncol = size(mat)
    nrow == ncol || error("expecting a square matrix")

    @match mat begin
        mat::IMatrix => OpValue.Identity(nrow)
        mat::PermMatrix => OpValue.Perm(nrow, mat)
        mat::SparseMatrixCSC => OpValue.Sparse(nrow, mat)
        mat::AbstractMatrix => OpValue.Dense(nrow, mat)
    end
end
    
for op in (:+, :-, :*)
    @eval function LinearAlgebra.$op(lhs::OpValue.Type, rhs::OpValue.Type)::OpValue.Type
        return LinearAlgebra.$op(mat(lhs), mat(rhs))
    end
end

function LinearAlgebra.kron(lhs::OpValue.Type, rhs::OpValue.Type)::OpValue.Type
    return kron(mat(lhs), mat(rhs))
end
    
end


for unaryop in (:det, :trace)
    @eval function LinearAlgebra.$unaryop(op::OpValue.Type)::Scalar.Type
        return LinearAlgebra.$unaryop(mat(op))
    end
end


partial_trace(op::OpValue.Type, m::Int, n::Int)::Scalar.Type = partial_trace(mat(op), m, n)


