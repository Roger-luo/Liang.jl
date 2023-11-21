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
