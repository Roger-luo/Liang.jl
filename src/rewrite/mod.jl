"""
The rewrite engine.
"""
module Rewrite

using DocStringExtensions
using Liang.Data.Prelude
using Liang.Tree

include("rule.jl")
include("pass.jl")
include("fixpoint.jl")
include("walk.jl")
include("chain.jl")

end # Rewrite
