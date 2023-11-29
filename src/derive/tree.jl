using Liang.Tree: Tree, ACSet

function derive_impl(::Val{:Tree}, mod::Module, type)
    throw(ArgumentError("derive[Tree] is only supported for data type defined via `@data`"))
end

function derive_impl(::Val{:Tree}, mod::Module, data::Module)
    return quote
        $(tree_derive_children(mod, data))
        $(tree_derive_map_children(mod, data))
        $(tree_derive_threaded_map_children(mod, data))
    end
end

function tree_derive_map_children(mod::Module, data::Module)
    body = tree_map_children(Val(:simple), mod, data, :f, :node)
    return quote
        function $Tree.generated_map_children(f, node::$data.Type)
            return $body
        end
    end
end

function tree_derive_threaded_map_children(mod::Module, data::Module)
    body = tree_map_children(Val(:spawn), mod, data, :f, :node)
    return quote
        function $Tree.generated_threaded_map_children(f, node::$data.Type)
            return $body
        end
    end
end

function tree_derive_n_children(mod::Module, data::Module)
    jl = JLIfElse()
    for variant_type in variants(data.Type)
        # scan static ones
        n_children = 0
        for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
            field_type == data.Type || continue
            n_children += 1
        end

        dynamic_children = []
        for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
            field_type <: Union{ACSet{data.Type},Vector{data.Type},Set{data.Type}} ||
                continue
            field_value = xcall(
                Reflection, :variant_getfield, :node, Val(variant_type.tag), idx
            ),
            push!(dynamic_children, :($Base.length($field_value)))
        end

        if isempty(dynamic_children)
            jl[:(vtype == $variant_type)] = quote
                return $n_children
            end
        else
            jl[:(vtype == $variant_type)] = quote
                return $n_children + $(xcall(Base, :+, dynamic_children...))
            end
        end
    end
    jl.otherwise = quote
        error("unreachable reached")
    end

    return quote
        function $Tree.n_children(node::$data.Type)
            vtype = $variant_type(node)
            return $(codegen_ast(jl))
        end
    end
end

function tree_derive_children(mod::Module, data::Module)
    jl = JLIfElse()
    for variant_type in variants(data.Type)
        children = [] # static children
        for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
            field_type == data.Type || continue
            push!(
                children,
                xcall(Reflection, :variant_getfield, :node, Val(variant_type.tag), idx),
            )
        end

        dynamic_children = []
        for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
            if field_type <: ACSet{data.Type}
                field_value = xcall(
                    Reflection, :variant_getfield, :node, Val(variant_type.tag), idx
                )
                push!(dynamic_children, :($Base.keys($field_value)))
            elseif field_type <: Vector{data.Type}
                field_value = xcall(
                    Reflection, :variant_getfield, :node, Val(variant_type.tag), idx
                )
                push!(dynamic_children, field_value)
            elseif field_type <: Set{data.Type}
                field_value = xcall(
                    Reflection, :variant_getfield, :node, Val(variant_type.tag), idx
                )
                push!(dynamic_children, field_value)
            else
                continue
            end
        end

        jl[:(vtype == $variant_type)] = if isempty(dynamic_children) # static only
            quote
                return $data.Type[$(children...)]
            end
        elseif isempty(children) && length(dynamic_children) == 1 # one dynamic only
            quote
                return $Base.collect($data.Type, $(dynamic_children[1]))
            end
        elseif isempty(children) # dynamic only
            @gensym chain
            quote
                $chain = $Iterators.flatten($(xtuple(dynamic_children...)))
                return $Base.collect($data.Type, $chain)
            end
        else
            error("mix of static and dynamic children is not supported yet\
                  please open an issue about your use case at\
                  https://github.com/Roger-luo/Liang.jl/issues/new")
        end
    end
    jl.otherwise = quote
        error("unreachable reached")
    end

    return quote
        function $Tree.children(node::$data.Type)
            vtype = $variant_type(node)
            return $(codegen_ast(jl))
        end
    end
end

function tree_map_children(
    async_mode::Val, mod::Module, data::Module, f::Symbol, node::Symbol
)
    @gensym vtype
    jl = JLIfElse()
    for variant_type in variants(data.Type)
        if is_singleton(variant_type)
            jl[:($vtype == $variant_type)] = quote
                return $node
            end
        else
            tasks_body = Expr(:block)
            input = []
            is_leaf = true
            for (idx, field_type) in enumerate(variant_fieldtypes(variant_type))
                field_value = xcall(
                    Reflection, :variant_getfield, node, Val(variant_type.tag), idx
                )
                @gensym value task
                if field_type <:
                    Union{data.Type,Vector{data.Type},Set{data.Type},Tree.ACSet{data.Type}} # children, use replacement
                    is_leaf = false
                    apply_f, retreive = tree_apply_f(async_mode, field_type, f, value, task)
                    push!(
                        tasks_body.args,
                        quote
                            $value = $field_value
                            $task = $apply_f
                        end,
                    )
                    push!(input, retreive)
                else # not children, use original
                    push!(input, field_value)
                end
            end

            jl[:($vtype == $variant_type)] = if is_leaf
                quote
                    return $node
                end
            else
                quote
                    $tasks_body
                    return $(xcall(variant_type, input...))
                end
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

function tree_apply_f(::Val{:spawn}, ::Type, f, value, task)
    return :($Threads.@spawn $f($value)), :($Threads.fetch($task))
end

function tree_apply_f(
    ::Val{:spawn}, ::Type{T}, f, value, task
) where {T<:Union{ACSet,Vector,Set}}
    return :($Threads.@spawn $Tree.threaded_map($f, $value)), :($Threads.fetch($task))
end

function tree_apply_f(::Val, ::Type, f, value, task)
    return :($f($value)), task
end

function tree_apply_f(::Val, ::Type{T}, f, value, task) where {T<:Union{ACSet,Vector,Set}}
    return :($Base.map($f, $value)), task
end
