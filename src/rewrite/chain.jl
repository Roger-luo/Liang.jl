struct Chain{Rs <: Tuple}
    maps::Rs    
end

Chain(maps...) = Chain(maps)

function (p::Chain)(x)
    for map in p.maps
        y = map(x)
        if !isnothing(y)
            x = y
        end
    end
    return x
end

function Base.show(io::IO, p::Chain)
    print(io, "Chain(")
    for (idx, map) in enumerate(p.maps)
        idx > 1 && print(io, ", ")
        print(io, map)
    end
    print(io, ")")
end
