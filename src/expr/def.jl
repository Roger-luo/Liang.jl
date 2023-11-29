"""
    @def <name>::<type>

Create a variable definition of given type.
"""
macro def(defs...)
    return quote
        $(esc(def_m(defs)))
        nothing
    end
end

function def_m(defs)
    expr_map(defs) do def
        Meta.isexpr(def, :(::)) || error("expect type annotation, got: $def")
        length(def.args) == 2 || error("expect name, got: $def")
        name, type = def.args
        mod = if type === :Scalar
            Scalar
        elseif type === :Index
            Index
        elseif type === :Op
            Op
        elseif type === :State
            State
        else
            error("expect Scalar, Index or Op, got: $type")
        end
        return quote
            $name = $mod.Variable(; name=$(QuoteNode(name)))
        end
    end
end
