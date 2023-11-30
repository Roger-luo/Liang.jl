using Liang.Expression: Variable, Index, @index_str, remove_empty_add, ACSet, MergeNested
using Liang.Tree

remove_empty_add(Index.Add)(Index.Add(0, ACSet(index"i" => 1))) == index"i"
transform = MergeNested{Index.Type,Int}(Index.Add) do coeffs, term_coeffs, val
    # val * (term.coeffs + sum[sub_val[i] * sub_terms[i]])
    # = val * term.coeffs + sum[val * sub_val[i] * sub_terms[i]]
    coeffs + val * term_coeffs
end

t = index"i" + index"j" + index"k"
transform(t) == Index.Add(0, ACSet(index"i" => 1, index"j" => 1, index"k" => 1))
