


@data InterpResult begin
    Result(Any)
    Error(String)
end

Base.show(io::IO, x::InterpResult.Type) = begin
    @match x begin
        InterpResult.Result(x) => print(io, x)
        InterpResult.Error(msg) => print(io, msg)
    end
end

for binary_op in [:max, :min, :kron, :+, :*, :/, :^]
    @eval function Base.$binary_op(x::InterpResult.Type, y::InterpResult.Type)
        @match (x, y) begin
            (InterpResult.Result(x), InterpResult.Result(y)) => InterpResult.Result($binary_op(x, y))
            (InterpResult.Error(msg), _) => InterpResult.Error(msg)
            (_, InterpResult.Error(msg)) => InterpResult.Error(msg)
        end
    end
    @eval function Base.$binary_op(x::InterpResult.Type, y)
        @match x begin
            InterpResult.Result(x) => InterpResult.Result($binary_op(x, y))
            InterpResult.Error(msg) => InterpResult.Error(msg)
        end
    end
    @eval function Base.$binary_op(x, y::InterpResult.Type)
        @match y begin
            InterpResult.Result(y) => InterpResult.Result($binary_op(x, y))
            InterpResult.Error(msg) => InterpResult.Error(msg)
        end
    end
end

for unary_op in [:-, :adjoint, :conj, :abs, :exp, :log, :sqrt]
    @eval function Base.$unary_op(x::InterpResult.Type)
        @match x begin
            InterpResult.Result(x) => InterpResult.Result($unary_op(x))
            InterpResult.Error(msg) => InterpResult.Error(msg)
        end
    end
end

