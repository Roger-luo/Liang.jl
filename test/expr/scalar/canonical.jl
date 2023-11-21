using Liang.Data.Prelude
using Liang.Expression.Prelude
using Liang.Expression:
    Expression,
    merge_nested_prod,
    merge_nested_sum,
    merge_pow_prod,
    prod_to_pow,
    pow_one,
    merge_sum_prod,
    remove_empty_sum
using Liang.Tree
using Liang.Rewrite: Fixpoint, Chain, Pre

p = Pre(Fixpoint(Chain(
    merge_nested_sum,
    merge_nested_prod,
    merge_pow_prod,
    prod_to_pow,
    pow_one,
    merge_sum_prod,
    remove_empty_sum,
)))

p(scalar"i" * 2 * scalar"j"^2)
p(Scalar.Prod(1, Dict(scalar"i"^3 => 1)))
p(1 + 2 * scalar"i"^3 + 3 * scalar"i"^3)
p(0 - 2 * scalar"i"^3 + 3 * scalar"i"^3)
p(scalar"i" * 2 * scalar"j"^2)
p(scalar"i" * 2 * scalar"j"^(scalar"i" + 1))
