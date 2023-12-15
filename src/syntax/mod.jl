module Syntax

using DocStringExtensions
using Liang.Match: @match
using Liang.Tree: Tree, ACSet
using Liang.Expression.Prelude
using Liang.Canonicalize: canonicalize
using LinearAlgebra: LinearAlgebra
using ExproniconLite: expr_map, JLFunction, codegen_ast, name_only
using Preferences: @load_preference

const syntax_option = @load_preference(
    "syntax", Dict("canonicalize" => true, "validate" => true)
)

"""
    @syntax <function definition>

Mark a function definition as a syntax definition of
the language. This macro will do the following:

- run `canonicalize` on the function return value
- run `validate` on the function return value
"""
macro syntax(expr)
    return esc(syntax_m(__source__, expr))
end

function forward_function_args(args)
    isnothing(args) && return []
    return map(args) do x
        Meta.isexpr(x, :...) && return Expr(:..., name_only(x.args[1]))
        return name_only(x)
    end
end

function syntax_m(line, expr)
    !syntax_option["canonicalize"] && !syntax_option["validate"] && return expr

    jl = JLFunction(expr)
    syntax_name = jl.name
    jl.name = gensym(string(jl.name))

    @gensym output_expr
    args = forward_function_args(jl.args)
    kwargs = forward_function_args(jl.kwargs)
    body = Expr(:block, line, :($output_expr = $(jl.name)($(args...); $(kwargs...))))
    if syntax_option["canonicalize"]
        push!(body.args, :($output_expr = $canonicalize($output_expr)))
    end

    # if syntax_option["validate"]
    #     push!(body.args, :($output_expr = $validate($output_expr)))
    # end

    push!(body.args, :(return $output_expr))

    overload = JLFunction(;
        jl.head,
        name=syntax_name,
        jl.args,
        jl.kwargs,
        jl.rettype,
        # jl.generated, # no need to inherit this
        jl.whereparams,
        jl.line,
        jl.doc,
        body,
    )

    return quote
        $(codegen_ast(jl))
        $(codegen_ast(overload))
    end
end

include("var.jl")
include("basis.jl")
include("index.jl")
include("op.jl")
include("region.jl")
include("scalar.jl")
include("state.jl")
include("tensor.jl")
include("def.jl")
include("prelude.jl")

end # Syntax
