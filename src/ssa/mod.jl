module SSA

using Liang.Data: @data
using Liang.Match: @match
using Liang.Data.Prelude
using Liang.Expression.Prelude
using Liang.Analysis: vars
using DocStringExtensions

include("data.jl")
include("lower.jl")
include("show.jl")

end # SSA
