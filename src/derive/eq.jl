function derive_impl(::Val{:PartialEq}, mod::Module, type::Module)
    jl = JLIfElse()
    for variant_type in variants(type.Type)
        cond = Expr(:&&)
        for name in variant_fieldnames(variant_type)
            lhs_val = xcall(Reflection, :variant_getfield, :lhs, Val(variant_type.tag), QuoteNode(name))
            rhs_val = xcall(Reflection, :variant_getfield, :rhs, Val(variant_type.tag), QuoteNode(name))
            eq_expr = xcall(Base, :(==), lhs_val, rhs_val)
            push!(cond.args, eq_expr)
        end
        jl[:(vtype == $variant_type)] = quote
            return $cond
        end
    end
    jl.otherwise = quote
        return false
    end

    return quote
        Base.@constprop :aggressive function $Base.:(==)(lhs::$type.Type, rhs::$type.Type)
            variant_tag(lhs) == variant_tag(rhs) || return false
            vtype = $variant_type(lhs)
            $(codegen_ast(jl))
        end
    end
end
