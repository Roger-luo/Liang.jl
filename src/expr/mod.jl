"""
Definition & Construction of Expressions
"""
module Expression

using Liang.Tree: Tree
using Liang.Data: Data
using Liang.Data.Prelude
using Liang.Match: @match
using Liang.Derive: @derive
using LinearAlgebra: LinearAlgebra

struct Routine{E}
    name::Symbol
    # Variable of the same type E
    args::Vector{Symbol}
    body::E
end

include("scalar/mod.jl")
include("basis/mod.jl")
include("state/mod.jl")
include("region/mod.jl")
include("op/mod.jl")
include("tensor/mod.jl")

end # Expression
