module Match

using Liang.Data: Data, @data, isa_variant

include("data.jl")
include("show.jl")
include("scan.jl")
include("macro.jl")
include("emit/mod.jl")

end # Match
