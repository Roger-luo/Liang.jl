module Interpret

using Liang.Match: @match
using Liang.Tools.Interface: @interface, INTERFACE
using Liang.Expression.Prelude
using Liang.Analysis.Prelude
using LinearAlgebra: LinearAlgebra, det, kron
using LuxurySparse: PermMatrix, IMatrix
using SparseArrays: sparse, SparseMatrixCSC, nzrange

struct InterpretedFn{E}
    name::Symbol
    args::Dict{Variable.Type,E}
    body::E
end

function InterpretedFn(name, body)
    return InterpretedFn(name, vars(body), body)
end

try_convert(node, val) = val
function try_convert(node::Scalar.Type, val)
    @match node begin
        Scalar.Variable(x) => convert(Num.Type, val)
        Scalar.Subscript(ref) => val
        _ => error("invalid variable node")
    end
end

function (fn::InterpretedFn)(; kwargs...)
    scope = Dict{Variable.Type,Any}()
    for (name, val) in kwargs
        x = Variable.Slot(name)
        haskey(fn.args, x) || error("unknown variable: $x")
        scope[x] = try_convert(fn.args[x], val)
    end
    return interpret(fn.body, scope)
end

include("scalar/mod.jl")
include("index.jl")

end # module
