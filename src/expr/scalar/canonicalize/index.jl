function simple_const_fold(node::Index.Type)
    @match node begin
        Index.Add(Index.Constant(x), Index.Constant(y)) => Index.Constant(x + y)
        Index.Sub(Index.Constant(x), Index.Constant(y)) => Index.Constant(x - y)
        Index.Mul(Index.Constant(x), Index.Constant(y)) => Index.Constant(x * y)
        Index.Div(Index.Constant(x), Index.Constant(y)) => Index.Constant(x ÷ y)
        Index.Rem(Index.Constant(x), Index.Constant(y)) => Index.Constant(x % y)
        Index.Max(Index.Constant(x), Index.Constant(y)) => Index.Constant(max(x, y))
        Index.Min(Index.Constant(x), Index.Constant(y)) => Index.Constant(min(x, y))
        Index.Pow(Index.Constant(x), Index.Constant(y)) => Index.Constant(x^y)
        Index.Neg(Index.Constant(x)) => Index.Constant(-x)
        Index.Abs(Index.Constant(x)) => Index.Constant(abs(x))
        Index.AssertEqual(x, x) => x
        _ => node
    end
end

# function prop_infty(node::Index.Type)
#     @match node begin
#         Index.Add(Index.Inf, Index.Inf) => Index.Inf
#         Index.Add(_, Index.Inf) || Index.Add(Index.Inf, _) => Index.Inf
#         Index.Sub(Index.Inf, Index.Inf) => Index.Inf
#         Index.Sub(_, Index.Inf) || Index.Sub(Index.Inf, _) => Index.Inf
#         Index.Mul(Index.Inf, Index.Inf) => Index.Inf
#         Index.Mul(Index.Inf, -Index.Inf) || Index.Mul(-Index.Inf, Index.Inf) => -Index.Inf
#         Index.Div(Index.Inf, Index.Inf) => Index.Inf
#         Index.Div(Index.Inf, -Index.Inf) || Index.Div(-Index.Inf, Index.Inf) => -Index.Inf
#         Index.Max(Index.Inf, Index.Inf) => Index.Inf
#         Index.Max(Index.Inf, _) || Index.Max(_, Index.Inf) => Index.Inf
#         Index.Min(Index.Inf, Index.Inf) => Index.Inf
#         Index.Min(Index.Inf, x) || Index.Min(x, Index.Inf) => x
#     end
# end

function canonicalize(node::Index.Type)
    p = Pre(Fixpoint(Chain(simple_const_fold)))
    return p(node)
end
