function Base.show(io::IO, node::Index.Type)
    return Tree.Print.inline(io, node)
end
