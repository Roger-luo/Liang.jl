@data Stmt begin
    Index(Index.Type)
    Scalar(Scalar.Type)
    Region(Region.Type)
    Op(Op.Type)
    State(State.Type)
    Tensor(Tensor.Type)
end

"""
Structural Control Flow
"""
@data CF begin
    None
    Break
    Continue

    struct If
        cond::Stmt.Type
        then::CF
        otherwise::CF
    end

    struct While
        cond::Stmt.Type
        body::CF
    end

    struct For
        index::Vector{Index.Type}
        region::Region.Type
        body::CF
    end

    Return(Stmt.Type)

    Block(Vector{Stmt.Type})
end
