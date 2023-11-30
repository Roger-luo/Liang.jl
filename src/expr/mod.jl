"""
Definition & Construction of Expressions
"""
module Expression

using Liang.Tree: Tree, ACSet
using Liang.Data: Data
using Liang.Data.Prelude
using Liang.Match: @match
using Liang.Derive: @derive
using Liang.Rewrite: Fixpoint, Chain, Pre, Post
using Liang.Traits: Hash
using Liang.Tools.Interface
using SparseArrays: SparseMatrixCSC
using LinearAlgebra: LinearAlgebra
using Transducers: Map, tcollect
using ExproniconLite: expr_map
using FunctionWrappers: FunctionWrapper
using DynamicQuantities:
    DynamicQuantities, dimension, Quantity, SymbolicDimensions, DEFAULT_DIM_BASE_TYPE
using DocStringExtensions

include("interface.jl")
include("tools.jl")
include("var.jl")
include("index/mod.jl")
include("scalar/mod.jl")
include("basis/mod.jl")
include("region/mod.jl")
include("state/mod.jl")
include("op/mod.jl")
# include("tensor/mod.jl")
# include("routine.jl")
# include("def.jl")
include("prelude.jl")

end # Expression
