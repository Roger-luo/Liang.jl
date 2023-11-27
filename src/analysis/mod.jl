module Analysis

using Liang.Data.Prelude
using Liang.Match: @match
using Liang.Expression.Prelude
using Liang.Tree: children
using Liang.Tools.Interface: @interface, INTERFACE
using Liang: not_implemented_error
using FunctionWrappers: FunctionWrapper

include("cache.jl")
include("ctx.jl")
include("scalar/mod.jl")
include("op/mod.jl")

include("vars.jl")
include("prelude.jl")

end # Analysis
