using Liang.Match: Pattern, expr2pattern
using Liang.Expression: Scalar

expr2pattern(:(1:10))
expr2pattern(:(1:x:10))
expr2pattern(:(x + 1))
expr2pattern(:(Pattern.Wildcard))
x = expr2pattern(:(Pattern.Quote(x)))
expr2pattern(:(Scalar.Pow(x, 2)))
expr2pattern(:([a + b for a in 1:10, b in 1:10]))
x = expr2pattern(:([a + b::Int for a in 1:10, b in 1:10]))
x = expr2pattern(:([a + b::Int for a in A, b in B]))
expr2pattern(:(sum(xs...)))
expr2pattern(:([1, x, 3]))
expr2pattern(:([1 x 3]))
expr2pattern(:([1 x; y]))
expr2pattern(:([
    x
    y
    z
]))
expr2pattern(:(
    [
        1 2;3 4;;;
        x 6;7 8;;;
        9 0;2 3;;;
    ]
))

expr2pattern(:(Float64[1, x, 3]))
expr2pattern(:(Float64[1 x 3]))
expr2pattern(:(Float64[1 x; y]))
expr2pattern(:(Float64[
    x
    y
    z
]))
expr2pattern(:(
    Float64[
        1 2;3 4;;;
        x 6;7 8;;;
        9 0;2 3;;;
    ]
))

expr2pattern(:((a, b) && c))
expr2pattern(:((a, b) || c))
expr2pattern(:(::Int))
