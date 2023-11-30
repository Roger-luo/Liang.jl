@data State begin
    Variable(Variable.Type)
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
