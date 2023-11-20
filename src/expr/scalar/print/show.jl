function Data.show_data(io::IO, node::Num.Type)
    return Tree.inline_print(io, node)
end

function Data.show_data(io::IO, node::Scalar.Type)
    return Tree.inline_print(io, node)
end

function Data.show_data(io::IO, node::Index.Type)
    return Tree.inline_print(io, node)
end
