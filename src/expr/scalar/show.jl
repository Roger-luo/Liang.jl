for E in [:Num, :Index, :Scalar]
    @eval function Base.show(io::IO, node::$E.Type)
        return Tree.inline_print(io, node)
    end
end
