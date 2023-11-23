"""
$INTERFACE

Interpret an expression with given variable assignments.
"""
@interface interpret(node::E, assign::Dict{E, V}) where {E, V} = not_implemented_error()

"""
$INTERFACE

Partially eval an expression with given variable assignments.
"""
@interface partial(node::E, assign::Dict{E, V}) where {E, V} = not_implemented_error()

struct InterpretFn{E}
    expr::E
    vars::Dict{Symbol, E}
end

InterpretFn(expr::E) where E = InterpretFn(expr, vars(expr))

function Base.show(io::IO, fn::InterpretFn)
    print(io, "InterpretFn: ")
    length(fn.vars) > 1 && print(io, "(")
    for (idx, var) in enumerate(keys(fn.vars))
        print(io, var)
        if idx < length(fn.vars)
            print(io, ", ")
        end
    end
    length(fn.vars) > 1 && print(io, ")")
    print(io, " -> ")
    print(io, fn.expr)
end

function (fn::InterpretFn{Index.Type})(;kw...)
    assign = Dict{Index.Type, Int}(fn.vars[k] => Int(v) for (k, v) in kw)
    return interpret(fn.expr, fn.vars, assign)::Int
end

function (fn::InterpretFn{Scalar.Type})(;kw...)
    assign = Dict{Scalar.Type, Num.Type}(fn.vars[k] => convert(Num.Type, v) for (k, v) in kw)
    return interpret(fn.expr, fn.vars, assign)::Num.Type
end

function interpret(node::Index.Type, vars::Dict{Symbol, Index.Type}, assign::Dict{Index.Type, Int})
    for v in values(vars)
        haskey(assign, v) || error("missing assignment for $v")
    end

    @match partial(node, assign) begin
        Index.Constant(value) => value
        failed => error("failed interpret $failed")
    end
end

for (E, V) in [(Index, Int), (Scalar, Num.Type)]
    @eval function partial(node::$E.Type, assign::Dict{$E.Type, $V})
        function substitute(node::$E.Type)
            if haskey(assign, node)
                return $E.Constant(assign[node])
            else
                return node
            end
        end
        p = Chain(substitute, canonicalize) |> Pre |> Post
        return p(node)
    end
end
