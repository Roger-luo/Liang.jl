module Liang

include("err.jl")
include("tools/mod.jl")
include("traits/mod.jl")

# data structures
include("data/mod.jl")
include("tree/mod.jl")
include("derive/mod.jl")
include("match/mod.jl")

# generic rewrite engine
include("rewrite/mod.jl")

# quantum stuff
include("expr/mod.jl")
include("analysis/mod.jl")
include("interpret/mod.jl")
include("canonicalize/mod.jl")
include("syntax/mod.jl")
# eval
# include("eval/mod.jl")

# include("ssa/mod.jl")

include("prelude.jl")
include("precompile.jl")

end # Liang
