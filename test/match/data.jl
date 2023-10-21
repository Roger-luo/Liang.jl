using Liang.Match: Match, EmitInfo, Pattern, expr2pattern, PatternInfo
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

struct Foo
    x::Int
    y::Int
end

info = EmitInfo(Main, :x, quote
    (a, b) => a + b
    (a, b) && c => a + b
    Int[1, y] => y
    Pattern.Variable(a) => a
    Foo(a, b) => (a, b)
end)

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[1])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[3])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[4])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[5])(:x)
pinfo.scope
