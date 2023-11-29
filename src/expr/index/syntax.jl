Base.abs(x::Index.Type) = Index.Abs(x)

"""
$SIGNATURES

Assert that the index `lhs` and `rhs` are equal.
"""
function assert_equal(lhs::Index.Type, rhs::Index.Type, msg::String="")
    lhs == rhs && return lhs # short-circuit
    return Index.AssertEqual(lhs, rhs, msg)
end

Base.:(+)(x::Index.Type) = x
Base.:(-)(x::Index.Type) = Index.Add(Dict(x => -1))
Base.:(+)(lhs::Index.Type, rhs::Index.Type) = Index.Add(ACSet(lhs => 1, rhs => 1))
Base.:(+)(lhs::Index.Type, rhs::Int) = lhs + Index.Constant(rhs)
Base.:(+)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) + rhs
Base.:(-)(lhs::Index.Type, rhs::Index.Type) = Index.Add(ACSet(lhs => 1, rhs => -1))
Base.:(-)(lhs::Index.Type, rhs::Int) = lhs - Index.Constant(rhs)
Base.:(-)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) - rhs
Base.:(*)(lhs::Index.Type, rhs::Index.Type) = Index.Mul(ACSet(lhs => 1, rhs => 1))
Base.:(*)(lhs::Index.Type, rhs::Int) = lhs * Index.Constant(rhs)
Base.:(*)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) * rhs
Base.:(/)(lhs::Index.Type, rhs::Index.Type) = Index.Div(lhs, rhs)
Base.:(/)(lhs::Index.Type, rhs::Int) = Index.Div(lhs, rhs)
Base.:(/)(lhs::Int, rhs::Index.Type) = Index.Div(lhs, rhs)
Base.:(\)(lhs::Index.Type, rhs::Index.Type) = rhs / lhs
Base.:(\)(lhs::Index.Type, rhs::Int) = rhs / lhs
Base.:(\)(lhs::Int, rhs::Index.Type) = rhs / lhs
Base.:(^)(lhs::Index.Type, rhs::Index.Type) = Index.Pow(lhs, rhs)
Base.:(^)(lhs::Index.Type, rhs::Int) = Index.Pow(lhs, rhs)
Base.:(^)(lhs::Int, rhs::Index.Type) = Index.Pow(lhs, rhs)
Base.rem(lhs::Index.Type, rhs::Index.Type) = Index.Rem(lhs, rhs)
Base.rem(lhs::Index.Type, rhs::Int) = Index.Rem(lhs, rhs)
Base.rem(lhs::Int, rhs::Index.Type) = Index.Rem(lhs, rhs)
Base.max(lhs::Index.Type, rhs::Index.Type) = Index.Max(Set([lhs, rhs]))
Base.max(lhs::Index.Type, rhs::Int) = Index.Max(Set([lhs, Index.Constant(rhs)]))
Base.max(lhs::Int, rhs::Index.Type) = Index.Max(Set([Index.Constant(lhs), rhs]))
Base.min(lhs::Index.Type, rhs::Index.Type) = Index.Min(Set([lhs, rhs]))
Base.min(lhs::Index.Type, rhs::Int) = Index.Min(Set([lhs, Index.Constant(rhs)]))
Base.min(lhs::Int, rhs::Index.Type) = Index.Min(Set([Index.Constant(lhs), rhs]))
Base.abs(x::Index.Type) = Index.Abs(x)

"""
    @index_str

Create a `Index.Variable` from a string.
"""
macro index_str(s::AbstractString)
    return parse_var(Index.Variable, s)
end

function parse_var(f, s::AbstractString)
    if (m = match(r"%([0-9]+)", s); !isnothing(m))
        id = parse(Int64, m.captures[1])
        id > 0 || error("invalid SSA id: $id ≤ 0")
        return f(; name=Symbol(s), id)
    else
        return f(; name=Symbol(s))
    end
end
