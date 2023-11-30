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
        quote_name = QuoteNode(name)
        if type === :Scalar
            quote
                $name = $Scalar.Variable($quote_name)
            end
        elseif type in [:Natural, :Integer, :Rational, :Real, :Imag, :Complex]
            quote
                $name = $Scalar.Domain($Scalar.Variable($quote_name), $Domain.$type)
            end
        elseif type === :Index
            quote
                $name = $Index.Variable($quote_name)
            end
        elseif type === :Op
            quote
                $name = $Op.Variable($quote_name)
            end
        elseif type === :State
            quote
                $name = $State.Variable($quote_name)
            end
        else
            error("expect Scalar, Index or Op, got: $type")
        end
    end
end
