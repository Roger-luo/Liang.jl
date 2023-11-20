struct PassThrough{F}
    f::F
end

function (p::PassThrough)(node)
    ret = p.f(node)
    isnothing(ret) && return node
    return ret
end
