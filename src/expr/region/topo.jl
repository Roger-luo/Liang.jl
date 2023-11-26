"""
$TYPEDEF

A topological space ``(\\math{X}, \\math{T})`` consists of a set
``\\math{X}`` and a set ``\\math{T}`` of subsets, called open sets, of
``\\math{X}`` such that:

- ``∅ ∈ \\math{T}`` and ``\\math{X} ∈ \\math{T}``
- a finite intersection of members of ``\\math{T}`` is a member of
  ``\\math{T}``
- an arbitrary union of members of ``\\math{T}`` is a member of
  ``\\math{T}``

### Reference

Topological Toolkit: https://www.iue.tuwien.ac.at/phd/heinzl/node17.html
"""
struct Topology
    sets::Vector{Vector{Vector{Int64}}}
end

"""
$TYPEDEF

Enumerate over `p`-cells of a chain complex, where
`p` is specified by `enum`. Return the set of labels of the 
`q`-cells within a `p`-cell, where `q ≤ p` and `q` is
specified by `base`.

!!! note
    Cell needs to be a concrete expression (without variables)
    because the `Topology` is a finite set defined via `Vector`.
    Thus it is not possible to define variable size with the
    expression. On the other hand, we are expecting only non-variable
    use cases, e.g a finite lattice for the cell enumeration.
"""
struct CellEnum
    topo::Topology
    enum::Int # cell to enumerate
    base::Int # base cell label
end

"""
$TYPEDEF

A `CellMap` is a map between two cells of a chain complex.
"""
struct CellMap
    cell::CellEnum
    p1p2::Dict{Int,Set{Int}} # enum -> base
    p2p1::Dict{Int,Set{Int}} # base -> enum
end
