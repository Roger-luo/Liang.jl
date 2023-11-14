# maybe we should use the chain complex?
@data Region begin
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
