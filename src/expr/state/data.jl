@data State begin
    Wildcard
    Match(Symbol)

    """
    A variable state, useful when the state is a
    numerical state without much known structure,
    e.g a `Vector{ComplexF64}`.
    """
    struct Variable
        name::Symbol
        id::UInt64 = 0# SSA id
    end
    # this is mainly for making the algebra complete
    Zero
    # Eigen(Op, Int)
    # this is mainly for large unknown operators
    # for product state on small operators, use
    # Product with Basis instead
    Eigen(Any, Int)
    # A product state with configuration
    struct Product
        configs::Vector{Int}
        hash::Hash.Cache = Hash.Cache()
    end

    Kron(State, State)

    # e.g alpha * |0> + beta * |1>
    struct Add
        terms::ACSet{State,Scalar.Type}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Annotate
        expr::State
        basis::Basis
    end
end

@derive State[PartialEq, Hash, Tree]
