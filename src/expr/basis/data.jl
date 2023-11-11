@data Space begin
    Qubit
    Qudit(Int)
    Spin(Int)
    Product(Space, Space)
    Subspace(Space, Vector{Int})

    # TODO: the following is TBD
    GKP
    Gaussian
    Fermion(Int)
    Anyon(Int, Float64)
    Fock
    # TODO: generic subspace
end

@derive Space[PartialEq, Hash]

struct Basis
    op # Op
    space::Space.Type
end
