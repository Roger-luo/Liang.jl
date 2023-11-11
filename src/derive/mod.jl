module Derive

using ExproniconLite: expr_map, JLIfElse, codegen_ast, xcall
using ..Data.Prelude
using ..Data: Reflection

include("macro.jl")
include("eq.jl")
include("hash.jl")

end # Derive