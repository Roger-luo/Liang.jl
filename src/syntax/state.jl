"""
    prod"[0-9_]+"

Create a `State.Product` from a string of configurations.
The range of configuration is from 0 to 9, `_` is ignored,
for larger range, use `State.Product(Vector{Int})` directly.
"""
macro prod_str(s::String)
    configs = map(Iterators.filter(!isequal('_'), s)) do ch
        parse(Int, ch)
    end
    return State.Product(configs)
end

Base.kron(lhs::State.Type, rhs::State.Type) = State.Kron(lhs, rhs)

function Base.:(+)(lhs::State.Type, rhs::State.Type)
    lhs == rhs && return State.Add(Dict(lhs => 2))
    return State.Add(Dict(lhs => 1, rhs => 1))
end

function Base.:(-)(lhs::State.Type, rhs::State.Type)
    lhs == rhs && return State.Zero
    return State.Add(Dict(lhs => 1, rhs => -1))
end

function Base.:(%)(state::State.Type, basis::Basis)
    return State.Annotate(state, basis)
end
