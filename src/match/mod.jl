module Match

using ExproniconLite: expr_map, xtuple, xcall
using Liang.Data: Data, @data, isa_variant, SyntaxError, guess_type, Reflection
using Liang.Traits: PartialEq
using Liang.Derive: @derive

include("data.jl")
include("scan.jl")
include("macro.jl")
include("emit/mod.jl")
include("show.jl")

end # Match
