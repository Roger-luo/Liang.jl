function derive_impl(::Val{:Hash}, mod::Module, type::Module)
    jl = JLIfElse()
    for variant_type in variants(type.Type)
        body = :h
        for name in variant_fieldnames(variant_type)
            val = xcall(
                Reflection, :variant_getfield, :x, Val(variant_type.tag), QuoteNode(name)
            )
            body = :(hash($val, $body))
        end
        jl[:(vtype == $variant_type)] = quote
            return $body
        end
    end
    jl.otherwise = quote
        error("unreachable")
    end

    return quote
        Base.@constprop :aggressive function $Base.hash(x::$type.Type, h::UInt)
            h = hash($(hash(type)), h)
            h = hash(variant_tag(x), h)
            vtype = $variant_type(x)
            return $(codegen_ast(jl))
        end
    end
end
