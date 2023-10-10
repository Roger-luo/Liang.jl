"""
Provides the Algebraic Data Types (ADTs) for the project.
"""
module Data

using ExproniconLite: JLKwField, JLKwStruct, rm_lineinfo, rm_nothing, no_default

include("err.jl")
include("reflect.jl")
include("macro.jl")
include("syntax.jl")
include("scan.jl")
include("show.jl")
include("emit/mod.jl")
include("runtime.jl")

end # Data
