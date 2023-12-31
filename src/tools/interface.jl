module Interface

using ExproniconLite: JLFunction, name_only, no_default
using DocStringExtensions: DocStringExtensions, Abbreviation, SIGNATURES, TYPEDEF
export @interface, INTERFACE, INTERFACE_LIST
const INTERFACE_STUB = Symbol("#INTERFACE_STUB#")

"""
$TYPEDEF

The signature information of an interface method.

!!! note
    This is only used for printing for now. Thus we do not store
    the actual type signature at the moment. We should think about
    how to store the type signature and use this info in the future.
"""
Base.@kwdef struct InterfaceMethod
    name::Symbol
    arg_names::Vector{Symbol}
    arg_types::Vector{Any}
    kwargs_names::Vector{Symbol}
    kwargs_types::Vector{Any}
    kwargs_defaults::Vector{Any}
    where_params::Vector{Any}
    return_type
end

function Base.show(io::IO, im::InterfaceMethod)
    print(io, im.name, "(")
    for (i, arg) in enumerate(im.arg_names)
        print(io, arg)
        im.arg_types[i] === Any || print(io, "::", im.arg_types[i])
        i < length(im.arg_names) && print(io, ", ")
    end
    if !isempty(im.kwargs_names)
        !isempty(im.arg_names) && print(io, "; ")
        for (i, arg) in enumerate(im.kwargs_names)
            print(io, arg)
            im.kwargs_types[i] === Any || print(io, "::", im.kwargs_types[i])
            im.kwargs_defaults[i] === no_default || print(io, "=", im.kwargs_defaults[i])
            i < length(im.kwargs_names) && print(io, ", ")
        end
    end
    print(io, ")")

    if !isempty(im.where_params)
        print(io, " where {")
        for (i, param) in enumerate(im.where_params)
            print(io, param)
            i < length(im.where_params) && print(io, ", ")
        end
        print(io, "}")
    end

    return isnothing(im.return_type) || print(io, " -> ", im.return_type)
end

"""
    @interface <function definition>

Mark a method definition as interface. This will help
the toolchain generating docstring and other things. The
interface method is usually the most generic one that errors.
"""
macro interface(fn)
    return esc(interface_m(__module__, fn))
end

function interface_m(mod::Module, fn)
    jl = JLFunction(fn)
    return quote
        $(emit_interface_stub_storage(mod))
        $Core.@__doc__ $(fn)
        $Base.push!(
            $Base.get!(
                $Base.Set{$Interface.InterfaceMethod},
                $INTERFACE_STUB,
                $(QuoteNode(jl.name)),
            ),
            $(emit_interface_stub(mod, jl)),
        )
        $(emit_exports(mod, jl))
    end
end

function emit_exports(mod::Module, jl::JLFunction)
    mod === Main && return nothing
    return quote
        export $(jl.name)
    end
end

function emit_interface_stub_storage(mod::Module)
    type = :($Base.Dict{$Base.Symbol,$Base.Set{$Interface.InterfaceMethod}})
    if !isdefined(mod, INTERFACE_STUB)
        return :(const $INTERFACE_STUB = $type())
    end
    return nothing
end

function emit_interface_stub(mod::Module, jl::JLFunction)
    kwargs_names = isnothing(jl.kwargs) ? [] : name_only.(jl.kwargs)
    kwargs_types = isnothing(jl.kwargs) ? [] : type_only.(jl.kwargs)
    kwargs_defaults = if isnothing(jl.kwargs)
        []
    else
        map(jl.kwargs) do expr
            if Meta.isexpr(expr, :kw) || Meta.isexpr(expr, :(=))
                QuoteNode(expr.args[2])
            else
                no_default
            end
        end
    end

    interface_mt = InterfaceMethod(;
        name=jl.name,
        arg_names=name_only.(jl.args),
        arg_types=type_only.(jl.args),
        kwargs_names=kwargs_names,
        kwargs_types=kwargs_types,
        kwargs_defaults=kwargs_defaults,
        where_params=isnothing(jl.whereparams) ? [] : jl.whereparams,
        return_type=jl.rettype,
    )
    return interface_mt
end

function type_only(expr)
    expr isa Expr || return Any
    if Meta.isexpr(expr, :(::))
        length(expr.args) == 2 && return expr.args[2]
        return expr.args[1]
    end
    Meta.isexpr(expr, :kw) && return type_only(expr.args[1])
    Meta.isexpr(expr, :(=)) && return type_only(expr.args[1])
    Meta.isexpr(expr, :...) && return type_only(expr.args[1])
    return error("invalid expression: $expr")
end

# DocStringExtensions plugin
struct InterfaceSignature <: Abbreviation end

"""
    const INTERFACE = InterfaceSignature()

Similar to `SIGNATURES` but has more precise method
information obtained directly from the [`@interface`](@ref)
macro.
"""
const INTERFACE = InterfaceSignature()

function DocStringExtensions.format(::InterfaceSignature, buf, doc)
    binding = doc.data[:binding]
    object = Docs.resolve(binding)
    mod = parentmodule(object)
    if !isdefined(mod, INTERFACE_STUB)
        return nothing
    end
    stub = getfield(mod, INTERFACE_STUB)
    haskey(stub, nameof(object)) || return nothing
    # TODO: make this more preciese, don't pick
    # the first interface method, but pick the real one
    # based on the binding signature.
    return print(buf, "    ", first(stub[nameof(object)]))
end

struct InterfaceList <: Abbreviation end

"""
    const INTERFACE_LIST = InterfaceList()

List all the interface methods of a module. It shows
nothing if the binded object is not a module.
"""
const INTERFACE_LIST = InterfaceList()

function DocStringExtensions.format(::InterfaceList, buf, doc)
    binding = doc.data[:binding]
    mod = Docs.resolve(binding)
    mod isa Module || return nothing # NOTE: or error?

    isdefined(mod, INTERFACE_STUB) || return nothing
    stub = getfield(mod, INTERFACE_STUB)
    println(buf, "### Interfaces\n\n")
    for (name, methods) in stub
        println(buf, "    ", first(methods))
    end
end

end # Interface
