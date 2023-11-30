module Canonicalize

using Liang.Data.Prelude
using Liang.Expression.Prelude
using Liang.Tree: Tree, ACSet
using Liang.Match: @match
using Liang.Rewrite: Chain, Pre, Post, Fixpoint
using DocStringExtensions

include("merge/add2mul.jl")
include("merge/nested.jl")
include("merge/pow2mul.jl")
include("merge/mul2pow.jl")
include("fold/const.jl")
include("prop/conj.jl")
include("prop/div.jl")
include("remove/empty.jl")
include("remove/pow_one.jl")
include("sort/acset.jl")
include("entry.jl")

end # Canonicalize
