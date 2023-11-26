function Base.convert(::Type{Label.Type}, x::UnitRange)
    return Label.Range(x.start, 1, x.stop)
end

function Base.convert(::Type{Label.Type}, x::StepRange)
    return Label.Range(x.start, x.step, x.stop)
end

function Base.convert(::Type{Label.Type}, x::AbstractVector{<:Integer})
    return Label.Ordered(x')
end

function Base.convert(
    ::Type{Label.Type}, x::AbstractVector{E}
) where {E<:AbstractVector{<:Integer}}
    return Label.Ordered(hcat(x...))
end

function Base.convert(::Type{Label.Type}, x::AbstractMatrix{<:Integer})
    return Label.Ordered(x)
end

function Base.convert(::Type{Label.Type}, x::Set{<:AbstractVector{<:Integer}})
    return Label.Set(x)
end

module Lattice

using Liang.Expression: Scalar, Region, Label, Geometry

function sites(geometry::Geometry.Type)
    return Geometry.Cell(geometry, 0)
end

function bonds(geometry::Geometry.Type)
    return Geometry.Cell(geometry, 1)
end

function faces(geometry::Geometry.Type)
    return Geometry.Cell(geometry, 2)
end

function square(n::Integer; spacing::Real=1.0)
    return rect(n, n; spacing=(spacing, spacing))
end

function rect(n::Integer, m::Integer; spacing=(1.0, 1.0))
    return Geometry.Bounded(;
        geometry=Geometry.Scaled(;
            geometry=Geometry.Bravis(; sites=[0 0]', vectors=[1 0; 0 1]),
            scale=collect(Scalar.Type, spacing),
        ),
        shape=[n, m],
    )
end

function honeycomb(n::Integer, m::Integer=n; spacing=(1.0, 1.0))
    return Geometry.Bounded(;
        geometry=Geometry.Scaled(;
            geometry=Geometry.Bravis(;
                sites=Scalar.Type[
                    0.0 Scalar.Constant(1)/2
                    0.0 sqrt(Scalar.Constant(3))/2
                ],
                vectors=[
                    1.0 Scalar.Constant(1)/2
                    0.0 sqrt(Scalar.Constant(3))/2
                ],
            ),
            scale=collect(Scalar.Type, spacing),
        ),
        shape=[n, m],
    )
end

function triangular(n::Integer, m::Integer=n; spacing=(1.0, 1.0))
    return Geometry.Bounded(;
        geometry=Geometry.Scaled(;
            geometry=Geometry.Bravis(;
                sites=[0.0, 0.0]',
                vectors=[
                    1.0 Scalar.Constant(1)/2
                    0.0 sqrt(Scalar.Constant(3))/2
                ],
            ),
            scale=collect(Scalar.Type, spacing),
        ),
        shape=[n, m],
    )
end

function lieb(n::Integer, m::Integer=n; spacing=(1.0, 1.0))
    half = Scalar.Constant(1) / 2
    return Geometry.Bounded(;
        geometry=Geometry.Scaled(;
            geometry=Geometry.Bravis(;
                sites=[
                    0.0 half 0.0
                    0.0 0.0 half
                ], vectors=[
                    1.0 0.0
                    0.0 1.0
                ]
            ),
            scale=collect(Scalar.Type, spacing),
        ),
        shape=[n, m],
    )
end

function kagome(n::Integer, m::Integer=n; spacing=(1.0, 1.0))
    one = Scalar.Constant(1)
    sqrt3 = sqrt(Scalar.Constant(3))

    return Geometry.Bounded(;
        geometry=Geometry.Scaled(;
            geometry=Geometry.Bravis(;
                sites=[
                    0.0 one/4 Scalar.Constant(3)/4
                    0.0 sqrt3/4 sqrt3/4
                ],
                vectors=[
                    1.0 one/2
                    0.0 sqrt3/2
                ],
            ),
            scale=collect(Scalar.Type, spacing),
        ),
        shape=[n, m],
    )
end

end # module
