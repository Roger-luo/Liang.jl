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
include("merge/group.jl")
include("merge/mul2add.jl")
include("merge/subscript.jl")
include("fold/const.jl")
include("fold/identity.jl")
include("fold/zero.jl")
include("prop/conj.jl")
include("prop/div.jl")
include("prop/adjoint.jl")
include("prop/outer.jl")
include("remove/empty.jl")
include("remove/pow_one.jl")
include("sort/acset.jl")
include("entry.jl")

end # Canonicalize
