struct Chain{E,Maps<:Tuple}
    maps::Maps
end

Chain{E}(maps...) where {E} = Chain{E,typeof(maps)}(maps)

function (p::Chain{E})(x::E) where {E}
    for map in p.maps
        y = map(x)::Union{Nothing,E}
        if !isnothing(y)
            x = y
        end
    end
    return x::E
end

function Base.show(io::IO, p::Chain)
    print(io, "Chain(")
    for (idx, map) in enumerate(p.maps)
        idx > 1 && print(io, ", ")
        print(io, map)
    end
    return print(io, ")")
end
