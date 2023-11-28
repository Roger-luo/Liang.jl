"""
Definition & Construction of Expressions
"""
module Expression

using Liang.Tree: Tree, ACSet
using Liang.Data: Data
using Liang.Data.Prelude
using Liang.Match: @match
using Liang.Derive: @derive
using Liang.Rewrite: Fixpoint, Chain, Pre, Post
using Liang.Traits: Hash
using Liang.Tools.Interface
using LinearAlgebra: LinearAlgebra
using Transducers: Map, tcollect
using ExproniconLite: expr_map
using DynamicQuantities: Dimensions, DEFAULT_DIM_BASE_TYPE
using DocStringExtensions

struct Routine{E}
    name::Symbol
    # Variable of the same type E
    args::Vector{Symbol}
    body::E
end

"""
$INTERFACE

Run canonicalize on given expression. This is an API for
defining the canonicalization transform of an expression type.
"""
@interface (canonicalize(node::E)::E) where {E} = not_implemented_error()

include("scalar/mod.jl")
include("basis/mod.jl")
include("state/mod.jl")
include("region/mod.jl")
include("op/mod.jl")
include("tensor/mod.jl")
include("cf/mod.jl")

"""
    @def <name>::<type>

Create a variable definition of given type.
"""
macro def(defs...)
    return quote
        $(esc(def_m(defs)))
        nothing
    end
end

function def_m(defs)
    expr_map(defs) do def
        Meta.isexpr(def, :(::)) || error("expect type annotation, got: $def")
        length(def.args) == 2 || error("expect name, got: $def")
        name, type = def.args
        mod = if type === :Scalar
            Scalar
        elseif type === :Index
            Index
        elseif type === :Op
            Op
        elseif type === :State
            State
        else
            error("expect Scalar, Index or Op, got: $type")
        end
        return quote
            $name = $mod.Variable(; name=$(QuoteNode(name)))
        end
    end
end

include("prelude.jl")

end # Expression
