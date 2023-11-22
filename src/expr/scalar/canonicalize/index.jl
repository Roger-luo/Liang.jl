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

function canonicalize(node::Index.Type)
    p = Pre(Fixpoint(Chain(simple_const_fold)))
    return p(node)
end
