
Base.convert(::Type{OpValue.Type}, mat::AbstractMatrix) = 
    if mat isa IMatrix
        OpValue.Identity(size(mat,1))
    elseif mat isa PermMatrix
        new_mat = PermMatrix(mat.perm, convert.(Num.Type, mat.vals))
        OpValue.Perm(size(mat,1), new_mat)
    elseif issparse(mat)
        OpValue.Sparse(size(mat,1), mat)
    else
        OpValue.Dense(size(mat,1), mat)
    end


function mat(op_value::OpValue.Type)
    pauli(a::UInt8) = @match a begin
        0x00 => IMatrix(2)
        0x01 => PermMatrix([2, 1], [1, 1])
        0x02 => PermMatrix([2, 1], [1im, -1im])
        0x03 => PermMatrix([1, 2], [-1, 1])
    end

    @match op_value begin
        OpValue.Perm(nrows, A) => A
        OpValue.Dense(nrows, A) => A
        OpValue.Sparse(nrows, A) => A
        OpValue.Identity(nrows) => IMatrix(nrows)
        OpValue.Pauli(opstr) => begin
            result = mapreduce(pauli, kron, opstr)
            result isa IMatrix && return result
            PermMatrix(result.perm, convert.(Num.Type, result.vals))
        end
    end
end
