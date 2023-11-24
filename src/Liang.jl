module Liang

include("err.jl")
include("traits/mod.jl")
include("tools/mod.jl")

# data structures
include("data/mod.jl")
include("tree/mod.jl")
include("match/mod.jl")
include("derive/mod.jl")

# generic rewrite engine
include("rewrite/mod.jl")

# quantum stuff
include("expr/mod.jl")
include("analysis/mod.jl")
include("eval/mod.jl")

include("prelude.jl")
include("precompile.jl")

end # Liang
