"""
Region conceptually is equivalent to
an iterator that returns labels as `Vector{Index.Type}`.
This is used for specifying the following:

- reduction of sum expression.
- labels of sites, bonds, plaquettes, etc.

Formally, the `Region` is defined as an iterator of
`p`-cell from a chain complex. This is the most generic
way of defining a topology without specifying the geometry.

Implementation-wise, we use more structural expression to
represent the region to improve storage efficiency and
retain more information about user input.
"""
@data Label begin
    Extern(Any)

    struct Range
        start::Index.Type
        step::Index.Type
        stop::Index.Type
    end

    Set(Set{Vector{Index.Type}})
    Ordered(Matrix{Index.Type}) # <=> eachcol(x)
    Cell(CellEnum)
end

@derive Label[PartialEq, Hash]

"""
Similar to `Label`, except that the `Geometry` returns
a set of coordinates as `Set{Vector{Scalar.Type}}`.
"""
@data Geometry begin
    Extern(Any)

    struct Bravis
        vectors::Matrix{Index.Type}
    end

    struct BoundedBravis
        shape::Vector{Index.Type}
        vectors::Matrix{Index.Type}
    end
end

@derive Geometry[PartialEq, Hash]

@data Region begin
    Index(Label.Type)
    Geometry(Geometry.Type)
end

@derive Region[PartialEq, Hash]
