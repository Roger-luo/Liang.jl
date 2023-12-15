"""
The rewrite engine.

This module is highly-based on SymbolicUtils.
"""
module Rewrite

using DocStringExtensions
using Liang.Data.Prelude
using Liang.Tree
using FunctionWrappers: FunctionWrapper

include("pass.jl")
include("fixpoint.jl")
include("walk.jl")
include("chain.jl")

end # Rewrite
