using Liang.Tree: Tree

function derive_impl(::Val{:Tree}, mod::Module, type)
    throw(ArgumentError("derive[Tree] is only supported for data type defined via `@data`"))
end

function derive_impl(::Val{:Tree}, mod::Module, type::Module)
    return quote
        $(tree_derive_children(mod, type))
        $(tree_derive_map_children(mod, type))
        $(tree_derive_threaded_map_children(mod, type))
    end
end

function tree_derive_map_children(mod::Module, type::Module)
    body = tree_map_children(mod, type, :node) do value, task
        :(map($value)), task
    end

    return quote
        function $Tree.generated_map_children(map, node::$type.Type)
            return $body
        end
    end
end

function tree_derive_threaded_map_children(mod::Module, type::Module)
    body = tree_map_children(mod, type, :node) do value, task
        :($Threads.@spawn map($value)), :($Threads.fetch($task))
    end

    return quote
        function $Tree.generated_threaded_map_children(map, node::$type.Type)
            return $body
        end
    end
end

function tree_derive_n_children(mod::Module, type::Module)
    jl = JLIfElse()
    for variant_type in variants(type.Type)
        n_children = 0
        for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
            field_type == type.Type || continue
            n_children += 1
        end
        jl[:(vtype == $variant_type)] = quote
            return $n_children
        end
    end
    jl.otherwise = quote
        error("unreachable reached")
    end

    return quote
        function $Tree.n_children(node::$type.Type)
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

function tree_map_children(mapgen, mod::Module, type::Module, node::Symbol)
    @gensym vtype
    jl = JLIfElse()
    for variant_type in variants(type.Type)
        if is_singleton(variant_type)
            jl[:($vtype == $variant_type)] = quote
                return $node
            end
        else
            tasks_body = Expr(:block)
            children = []
            for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
                field_value = xcall(
                    Reflection, :variant_getfield, node, Val(variant_type.tag), idx
                )
                if field_type == type.Type # children, use replacement
                    @gensym value task
                    task_expr, value_expr = mapgen(value, task)
                    push!(
                        tasks_body.args,
                        quote
                            $value = $field_value
                            $task = $task_expr
                        end,
                    )
                    push!(children, value_expr)
                else # not children, use original
                    push!(children, field_value)
                end
            end
            jl[:($vtype == $variant_type)] = quote
                $tasks_body
                return $(xcall(variant_type, children...))
            end
        end
    end
    jl.otherwise = quote
        error("unreachable reached")
    end

    return quote
        $(vtype) = $variant_type($node)
        $(codegen_ast(jl))
    end
end
