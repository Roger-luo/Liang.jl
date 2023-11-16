using Liang.Tree: Tree

function derive_impl(::Val{:Tree}, mod::Module, type::Module)
    return quote
        $(tree_derive_children(mod, type))
        $(tree_derive_substitute(mod, type))
    end
end

function tree_derive_substitute(mod::Module, type::Module)
    jl = JLIfElse()
    for variant_type in variants(type.Type)
        if is_singleton(variant_type)
            jl[:(vtype == $variant_type)] = quote
                return node
            end
        else
            children = []
            for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
                field_value = xcall(
                    Reflection, :variant_getfield, :node, Val(variant_type.tag), idx
                )
                if field_type == type.Type # children, use replacement
                    @gensym value
                    push!(
                        children,
                        quote
                            $value = $field_value
                            $Base.get(replace, $value, $value)
                        end,
                    )
                else # not children, use original
                    push!(children, field_value)
                end
            end
            jl[:(vtype == $variant_type)] = quote
                return $(xcall(variant_type, children...))
            end
        end
    end

    return quote
        function $Tree.substitute(node::$type.Type, replace::Dict{$type.Type,$type.Type})
            vtype = $variant_type(node)
            return $(codegen_ast(jl))
        end
    end
end

function tree_derive_children(mod::Module, type::Module)
    jl = JLIfElse()
    for variant_type in variants(type.Type)
        children = []
        for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
            field_type == type.Type || continue
            push!(
                children,
                xcall(Reflection, :variant_getfield, :node, Val(variant_type.tag), idx),
            )
        end
        jl[:(vtype == $variant_type)] = quote
            return [$(children...)]
        end
    end
    jl.otherwise = quote
        error("unreachable reached")
    end

    return quote
        function $Tree.children(node::$type.Type)
            vtype = $variant_type(node)
            return $(codegen_ast(jl))
        end
    end
end
