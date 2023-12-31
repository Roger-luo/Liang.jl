"""
Provides the Algebraic Data Types (ADTs) for the project.
"""
module Data

using DocStringExtensions
using ExproniconLite: JLKwField, JLKwStruct, rm_lineinfo, rm_nothing, no_default
using Liang.Tools.Interface: INTERFACE_LIST

include("err.jl")
include("macro.jl")
include("syntax.jl")

include("reflect.jl")
using .Reflection

include("guess.jl")
include("scan.jl")
include("show.jl")
include("emit/mod.jl")
include("runtime.jl")
include("prelude.jl")

end # Data
