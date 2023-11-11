@data State begin
    Wildcard
    Match(Symbol)
    # Eigen(Op, Vector{Int}), e.g
    # |01010110> each is an eigenstate of Z
    Eigen(Any, Vector{Int})
    # A product state with configuration
    Product(Vector{Int})
    Kron(State, State)

    # e.g alpha * |0> + beta * |1>
    Sum(Dict{State, Scalar.Type})
    
    struct Annotate
        expr::State
        basis::Basis
    end
end

@derive State[PartialEq, Hash]
