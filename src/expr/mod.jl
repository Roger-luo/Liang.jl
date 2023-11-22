"""
Definition & Construction of Expressions
"""
module Expression

using Liang.Tree: Tree
using Liang.Data: Data
using Liang.Data.Prelude
using Liang.Match: @match
using Liang.Derive: @derive
using Liang.Rewrite: Fixpoint, Chain, Pre, Post
using LinearAlgebra: LinearAlgebra
using Transducers: Map, tcollect
using ExproniconLite: expr_map
using DocStringExtensions

struct Routine{E}
    name::Symbol
    # Variable of the same type E
    args::Vector{Symbol}
    body::E
end

include("scalar/mod.jl")
include("basis/mod.jl")
include("state/mod.jl")
include("region/mod.jl")
include("op/mod.jl")
include("tensor/mod.jl")

"""
    @def <name>::<type>

Create a variable definition of given type.
"""
macro def(defs...)
    return esc(def_m(defs))
end

function def_m(defs)
    expr_map(defs) do def
        Meta.isexpr(def, :(::)) || error("expect type annotation, got: $def")
        length(def.args) == 2 || error("expect name, got: $def")
        name, type = def.args
        if type === :Scalar
            return quote
                $name = $Scalar.Variable(;name=$(QuoteNode(name)))
            end
        elseif type === :Index
            return quote
                $name = $Index.Variable(;name=$(QuoteNode(name)))
            end
        elseif type === :Op
            return quote
                $name = $Op.Variable(;name=$(QuoteNode(name)))
            end
        else
            error("expect Scalar, Index or Op, got: $type")
        end
    end
end

include("prelude.jl")

end # Expression
