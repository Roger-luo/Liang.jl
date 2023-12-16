module Interpret

using Liang.Match: @match
using Liang.Tools.Interface: @interface, INTERFACE
using Liang.Expression.Prelude
using Liang.Analysis.Prelude

struct InterpretedFn{E}
    name::Symbol
    args::Vector{Variable.Type}
    body::E
end

function InterpretedFn(name, body)
    return InterpretedFn(name, collect(Variable.Type, keys(vars(body))), body)
end

function (fn::InterpretedFn)(args...)
    scope = Dict{Variable.Type,Any}()
    for (arg, val) in zip(fn.args, args)
        scope[arg] = val
    end
    return interpret(fn.body, scope)
end

include("index.jl")

end # module
