module Syntax

using DocStringExtensions
using Liang.Match: @match
using Liang.Tree: Tree, ACSet
using Liang.Expression.Prelude

include("var.jl")
include("basis.jl")
include("index.jl")
include("op.jl")
include("region.jl")
include("scalar.jl")
include("state.jl")
include("tensor.jl")
include("prelude.jl")

end # Syntax
