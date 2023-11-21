struct CharSet
    mid::String
    terminator::String
    skip::String
    dash::String
    trunc::String
    pair::String
end

function CharSet(name::Symbol=:unicode)
    if name == :unicode
        CharSet("├", "└", "│", "─", "⋮", " ⇒ ")
    elseif name == :ascii
        CharSet("+", "\\", "|", "--", "...", " => ")
    else
        throw(ArgumentError("unrecognized dfeault CharSet name: $name"))
    end
end

function text_print(io::IO, node)
    if is_leaf(node)
        print_node(io, node)
    else
    end
end
