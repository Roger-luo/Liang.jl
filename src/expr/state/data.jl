@data State begin
    Wildcard
    Match(Symbol)
    # this is mainly for making the algebra complete
    Zero
    # Eigen(Op, Int)
    # this is mainly for large unknown operators
    # for product state on small operators, use
    # Product with Basis instead
    Eigen(Any, Int)
    # A product state with configuration
    Product(Vector{Int})
    Kron(State, State)

    # e.g alpha * |0> + beta * |1>
    Add(Dict{State,Scalar.Type})

    struct Annotate
        expr::State
        basis::Basis
    end
end

@derive State[PartialEq, Hash]
