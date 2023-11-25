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

@derive Label[PartialEq, Hash, Show]

"""
Similar to `Label`, except that the `Geometry` returns
a set of coordinates as `Matrix{Scalar.Type}`.
"""
@data Geometry begin
    Extern(Any)

    struct Bravis
        sites::Matrix{Scalar.Type}
        vectors::Matrix{Scalar.Type}
    end

    # TODO: port Parallelpiped from Bloqade.jl
    struct Bounded
        geometry::Geometry.Type
        shape::Vector{Index.Type}
    end

    struct Scaled
        geometry::Geometry.Type
        scale::Vector{Scalar.Type}
    end

    """
    Return the p-cell of the specified geometry, e.g
    0-cell is the sites, 1-cell is the bonds, etc.
    `p` should be less equal to the dimension of the
    geometry.
    """
    struct Cell
        geometry::Geometry.Type
        p::Int
    end
end

@derive Geometry[PartialEq, Hash, Show]

@data Region begin
    Label(Label.Type)
    Geometry(Geometry.Type)
end

@derive Region[PartialEq, Hash, Show]
