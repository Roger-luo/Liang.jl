"""
Region conceptually is equivalent to
an iterator that returns `Vector{Int}`.
This is used for specifying the following:

- reduction of sum expression.
- a chain complex (e.g sites, bonds, plaquettes).

Formally, the `Region` is defined as a chain complex
over integer sets. Implementation-wise, we use more
structural expression to represent the region to improve
storage efficiency and retain more information about user
input.
"""
@data Region begin
    UnitRange(UnitRange{Int})

    struct ToInf
        start::Int
        step::Int
    end

    ListOfLocations(Matrix{Scalar.Type})

    struct BoundedBravis
        shape::Vector{Int}
        spacing::Scalar.Type
        cell_vectors::Matrix{Scalar.Type}
    end
end
