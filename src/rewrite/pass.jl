struct PassThrough{R}
    map::R
end

function (p::PassThrough)(node)
    ret = p.map(node)
    isnothing(ret) && return node
    return ret
end

Base.show(io::IO, p::PassThrough) = print(io, "PassThrough(", p.map, ")")
