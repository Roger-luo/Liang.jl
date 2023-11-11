"""
    @derive <type>[<traits>...]

Automatically derive traits for a concrete type. The following traits are supported:

- `PartialEq`
- `Hash`
"""
macro derive(expr)
    esc(derive_m(__module__, expr))
end

function derive_m(mod::Module, expr)
    Meta.isexpr(expr, :ref) || error("expected a ref expression")
    type_expr = expr.args[1]
    traits = expr.args[2:end]
    type = Base.eval(mod, type_expr)
    type isa Module || type isa DataType || error("expected a type")

    return expr_map(traits) do trait
        derive_impl(Val(trait), mod, type)
    end
end

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
    # NOTE: maybe we should unroll the loop here?
    return quote
        Base.@constprop :aggressive function $Base.:(==)(lhs::$type.Type, rhs::$type.Type)
            variant_tag(lhs) == variant_tag(rhs) || return false
            vtype = $variant_type(lhs)
            $(codegen_ast(jl))
        end
    end
end

function derive_impl(::Val{:Hash}, mod::Module, type::Module)
    jl = JLIfElse()
    for variant_type in variants(type.Type)
        body = :h
        for name in variant_fieldnames(variant_type)
            val = xcall(Reflection, :variant_getfield, :x, Val(variant_type.tag), QuoteNode(name))
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
            $(codegen_ast(jl))
        end
    end
end
