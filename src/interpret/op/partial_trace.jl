
function partial_trace(A::Matrix{T}, m::I, n::I) where {T,I<:Integer}
    result = zeros(T, m, m)
    for i in 1:m, j in 1:m, k in 1:n
        row = (i - 1) * n + k
        col = (j - 1) * n + k
        result[i, j] += A[row, col]
    end

    return result
end

function partial_trace(A::SparseMatrixCSC{T,I}, m::I, n::I) where {T,I}
    nzrows = I[]
    nzcols = I[]
    nzvals = T[]

    rows = rowvals(A)
    vals = nonzeros(A)
    ncol = size(A, 2)

    for col in 1:ncol
        j, k1 = divrem(col - 1, n)

        for ind in nzrange(A, j)
            row = rows[ind]
            i, k2 = divrem(row - 1, n)
            if k1 == k2 # trace along the diagonal of subspace
                push!(nzrows, i)
                push!(nzcols, j)
                push!(nzvals, vals[ind])
            end
        end
    end
    return sparse(nzrows, nzcols, nzvals, m, m)
end

function partial_trace(A::PermMatrix{T,I}, m::I, n::I) where {T,I}
    nzrows = I[]
    nzcols = I[]
    nzvals = T[]

    for (row, col) in enumerate(A.perm)
        i, k1 = divrem(row - 1, n)
        j, k2 = divrem(col - 1, n)
        if k1 == k2 # trace along the diagonal of subspace
            push!(nzrows, i)
            push!(nzcols, j)
            push!(nzvals, 1)
        end
    end

    return sparse(nzrows, nzcols, nzvals, m, m)
end
