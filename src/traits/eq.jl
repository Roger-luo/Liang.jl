module PartialEq

using Liang: not_implemented_error

"""
    eq(lhs, rhs) -> Bool

Check if `lhs` is equal to `rhs`. This is different from
`==` that it will error if this function is not overloaded
explicitly for this type.

!!! note
    `eq` will fallback to `Base.:(==)` if a method has been
    overloaded for `Base.:(==)`.
"""
function eq end

@static if VERSION >= v"1.10.0-DEV.873"
    # in 1.10 generated function needs to track world ages
    # https://github.com/JuliaLang/julia/pull/48611

    function generate_eq(world::UInt, source, self, lhs, rhs)
        tt = Tuple{typeof(==),lhs,rhs}
        table = Core.Compiler.InternalMethodTable(world)
        match, = Core.Compiler.findsup(tt, table)
        mt = match.method

        stub = Core.GeneratedFunctionStub(
            identity, Core.svec(:methodinstance, :lhs, :rhs), Core.svec()
        )
        if Tuple{typeof(==), Any, Any} <: mt.sig
            ret = :(not_implemented_error())
        else
            ret = :($Base.:(==)(lhs, rhs))
        end
        return stub(world, source, ret)
    end

    @eval function eq(lhs, rhs)
        $(Expr(:meta, :generated, generate_eq))
        return $(Expr(:meta, :generated_only))
    end
else # previous versions
    @generated function eq(lhs, rhs)
        tt = Tuple{typeof(==),lhs,rhs}
        world = Core.Compiler.get_world_counter()
        table = Core.Compiler.InternalMethodTable(world)
        match, = Core.Compiler.findsup(tt, table)
        mt = match.method

        if mt.sig.parameters[2] === Any && mt.sig.parameters[3] === Any
            return :(not_implemented_error())
        else
            return :(lhs == rhs)
        end
    end
end

ne(lhs, rhs) = !eq(lhs, rhs)

end # PartialEq
