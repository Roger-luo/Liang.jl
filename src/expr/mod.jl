"""
Definition & Construction of Expressions
"""
module Expression

using Liang.Data: Data, @data, isa_variant

include("scalar/mod.jl")
include("basis/mod.jl")
include("state/mod.jl")
include("op/mod.jl")

end # Expression
