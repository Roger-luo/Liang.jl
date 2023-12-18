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
using LuxurySparse: kron, PermMatrix, IMatrix, SDPermMatrix
using LinearAlgebra: LinearAlgebra, kron
using Transducers: Map, tcollect
using ExproniconLite: expr_map
using FunctionWrappers: FunctionWrapper
using DynamicQuantities:
    DynamicQuantities, dimension, Quantity, SymbolicDimensions, DEFAULT_DIM_BASE_TYPE
using DocStringExtensions

include("routine.jl")
include("interface.jl")
include("var.jl")
include("index/mod.jl")
include("scalar/mod.jl")
include("basis/mod.jl")
include("region/mod.jl")
include("state/mod.jl")
include("op/mod.jl")
include("tensor/mod.jl")
include("prelude.jl")

end # Expression
