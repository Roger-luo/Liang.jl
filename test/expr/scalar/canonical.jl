using Liang.Data.Prelude
using Liang.Expression.Prelude
using Liang.Expression:
    Expression,
    canonicalize,
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

canonicalize(scalar"i" * 2 * scalar"j"^2)
canonicalize(Scalar.Prod(1, Dict(scalar"i"^3 => 1)))
canonicalize(1 + 2 * scalar"i"^3 + 3 * scalar"i"^3)
canonicalize(0 - 2 * scalar"i"^3 + 3 * scalar"i"^3)
canonicalize(scalar"i" * 2 * scalar"j"^2)
canonicalize(scalar"i" * 2 * scalar"j"^(scalar"i" + 1))

scalar"i" * 2 * scalar"j"^(scalar"i" + 1) |> Tree.text_print
scalar"i" * 2 * scalar"j"^(scalar"i" + 1) |> canonicalize |> Tree.text_print
0 - 2 * scalar"i"^3 + 3 * scalar"i"^3 |> Tree.text_print
0 - 2 * scalar"i"^3 + 3 * scalar"i"^3 |> canonicalize |> Tree.text_print
scalar"i" * 2 * scalar"j"^(scalar"i" + 1) |> Data.pprint
