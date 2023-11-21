@data Space begin
    """
    Qubit space with 2 dimensions.
    """
    Qubit

    """
    Qudit space with `d` dimensions.
    """
    Qudit(Int)

    """
    Spin space with 2S + 1 dimensions.
    """
    Spin(Int)

    """
    Cartesian product of spaces.
    """
    Product(Space, Space)

    """
    Cartesian power of a space.
    """
    Pow(Space, Int)

    """
    Subspace of a space.
    """
    Subspace(Space, Vector{Int})

    # TODO: the following is TBD
    GKP
    Gaussian
    Fermion(Int)
    Anyon(Int, Float64)
    Fock
    # TODO: generic subspace
end

@derive Space[PartialEq, Hash, Tree]

struct Basis
    op # Op
    space::Space.Type
end
