abstract type Walk{R} end

struct Pre{R} <: Walk{R}
    map::R
    threaded::Bool
    thread_cutoff::Int
end

struct Post{R} <: Walk{R}
    map::R
    threaded::Bool
    thread_cutoff::Int
end

function Pre(map; threaded::Bool=false, thread_cutoff::Int=100)
    return Pre(map, threaded, thread_cutoff)
end

function Post(map; threaded::Bool=false, thread_cutoff::Int=100)
    return Post(map, threaded, thread_cutoff)
end

function ((p::Pre)(node::E)::E) where E
    is_leaf(node) && return p.map(node)::E
    node = p.map(node)::E
    is_leaf(node) && return node
    return if p.threaded && n_children(node) > p.thread_cutoff
        threaded_map_children(PassThrough(p), node)::E
    else
        map_children(PassThrough(p), node)::E
    end
end

function ((p::Post)(node::E)::E) where E
    is_leaf(node) && return p.map(node)::E
    node = if p.threaded && n_children(node) > p.thread_cutoff
        map_children(PassThrough(p), node)::E
    else
        threaded_map_children(PassThrough(p), node)::E
    end
    is_leaf(node) && return node::E
    return p.map(node)::E
end

function Base.show(io::IO, p::Walk)
    print(io, nameof(typeof(p)), "(")
    print(io, p.map)
    if p.threaded
        print(io, "; threaded=true")
        p.thread_cutoff != 100 && print(io, ", thread_cutoff=", p.thread_cutoff)
    end
    print(io, ")")
end
