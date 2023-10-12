module Match

using Liang.Data: Data, @data, isa_variant, SyntaxError

include("data.jl")
include("scan.jl")
include("macro.jl")
include("emit/mod.jl")
include("show.jl")

end # Match
