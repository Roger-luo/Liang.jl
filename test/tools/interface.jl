using Liang.Tools.Interface: @interface
using Liang.Data.Reflection
using Liang.Data
using Liang.Data.Prelude

@macroexpand @interface (children(node::T)::Vector{T}) where {T} = T[]

(children(node::T)::Vector{T}) where {T} = T[]

mt = methods(children)[1]

(foo(x::T; y::T)::Vector{T}) where {T} = 1
