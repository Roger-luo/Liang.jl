using Liang.Data.Prelude
using Liang.Expression.Prelude
using Liang.Expression: Expression,
    merge_nested_prod,
    merge_nested_sum,
    prod_to_pow,
    merge_sum_prod
using Liang.Tree

merge_nested_prod(scalar"i" * 2 * scalar"j"^2)
merge_nested_prod(2 * scalar"j"^2)
merge_nested_prod(Scalar.Prod(1, Dict(scalar"i" => 3)))
merge_nested_prod(Scalar.Prod(1, Dict(scalar"i"^3 => 1)))
merge_nested_sum(ex)

(x^3)^2
