module Syntax

using DocStringExtensions
using Liang.Match: @match
using Liang.Tree: Tree, ACSet
using Liang.Expression.Prelude
using Liang.Canonicalize: canonicalize
using LinearAlgebra: LinearAlgebra
using ExproniconLite: expr_map, JLFunction, codegen_ast, name_only

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

function syntax_m(line, expr)
    jl = JLFunction(expr)
    syntax_name = jl.name
    jl.name = gensym(string(jl.name))

    @gensym output_expr
    args = isnothing(jl.args) ? [] : name_only.(jl.args)
    kwargs = isnothing(jl.kwargs) ? [] : name_only.(jl.kwargs)
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
        body=Expr(
            :block,
            line,
            :($output_expr = $(jl.name)($(args...); $(kwargs...))),
            :($output_expr = $canonicalize($output_expr)),
            # :($output_expr = $validate($output_expr)),
            :(return $output_expr),
        ),
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
