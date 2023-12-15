"""
$INTERFACE

Interpret an expression with given variable assignments.
"""
@interface interpret(node::E, assign::Dict{E,V}) where {E,V} = not_implemented_error()

"""
$INTERFACE

Partially eval an expression with given variable assignments.
"""
@interface partial(node::E, assign::Dict{E,V}) where {E,V} = not_implemented_error()

struct PartialFn{E}
    expr::E
    vars::Dict{Symbol,E}
    hash::UInt64
end

PartialFn(expr::E) where {E} = PartialFn(expr, vars(expr), hash(expr))

function Base.show(io::IO, fn::PartialFn)
    print(io, "PartialFn: ")
    length(fn.vars) > 1 && print(io, "(")
    for (idx, var) in enumerate(keys(fn.vars))
        print(io, var)
        if idx < length(fn.vars)
            print(io, ", ")
        end
    end
    length(fn.vars) > 1 && print(io, ")")
    print(io, " -> ")
    return print(io, fn.expr)
end

# function (fn::PartialFn{Index.Type})(;kw...)
#     assign = Dict{Index.Type, Int}(fn.vars[k] => Int(v) for (k, v) in kw)
#     return interpret(fn.expr, fn.vars, assign)::Int
# end

function (fn::PartialFn{Index.Type})(scope::Dict{Symbol,Any})
    assign = Dict{Index.Type,Int}()
    for (k, v) in fn.vars
        haskey(scope, k) || continue
        assign[v] = convert(Int, scope[k])
    end
    return partial(fn.expr, fn.vars, assign)::Index.Type
end

function (fn::PartialFn{Scalar.Type})(scope::Dict{Symbol,Any}) end

for (E, V) in [(Index, Int), (Scalar, Num.Type)]
    @eval function partial(node::$E.Type, assign::Dict{$E.Type,$V})
        function substitute(node::$E.Type)
            if haskey(assign, node)
                return $E.Constant(assign[node])
            else
                return node
            end
        end
        p = Post(Pre(Chain{$E.Type}(substitute, canonicalize)))
        return p(node)
    end
end

function extern_partial(node::Scalar.Type, assign::Dict{Symbol,Any})
    function substitute(node::Scalar.Type)
        @match node begin
            Scalar.Subscript(ref, indices) => begin
                vals = map(indices) do index
                    PartialFn(index)(assign)
                end
                is_const = all(vals) do val
                    @match val begin
                        Index.Constant(_) => true
                        _ => false
                    end
                end
                if is_const && haskey(assign, ref)
                    obj = assign[ref]
                    idx = map(vals) do val
                        @match val Index.Constant(idx) => idx
                    end
                    return Scalar.Constant(obj[idx...])
                else
                    return Scalar.Subscript(ref, vals)
                end
            end
        end

        if haskey(assign, node)
            return Scalar.Constant(assign[node])
        else
            return node
        end
    end
end
