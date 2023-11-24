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
@data IndexRegion begin
    Extern(Any)
    UnitRange(UnitRange{Index.Type})
    StepRange(StepRange{Index.Type, Index.Type})
    struct OpenRange
        start::Index.Type
        step::Index.Type
    end

    Set(Set{Vector{Index.Type}})
    Ordered(Matrix{Index.Type}) # <=> eachcol(x)
    Cell(CellEnum)
end

"""
Similar to `IndexRegion`, except that the `Geometry` returns
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
