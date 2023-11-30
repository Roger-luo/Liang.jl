Base.show(io::IO, node::State.Type) = Tree.Print.inline(io, node)
Base.show(io::IO, ::MIME"text/plain", node::State.Type) = Tree.Print.text(io, node)

function Tree.Print.print_node(io::IO, node::State.Type)
    @match node begin
        State.Variable(x) => braket(io) do
            print(io, x)
        end
        State.Zero => print(io, "0")
        State.Eigen(op::Op.Type, n) => begin
            print(io, "Eigen(")
            Tree.Print.inline(io, op)
            print(io, ", ", n, ")")
        end
        State.Product(config) => braket(io) do
            Tree.Print.inline_list(IOContext(io, :precedence => 0), config)
        end
        State.Kron(lhs, rhs) => print(io, "⊗")
        State.Add(terms) => print(io, "+")
        State.Annotate(_, basis) => printstyled(io, "%", basis; color=:light_black)
    end
end

function Tree.Print.is_infix(node::State.Type)
    @match node begin
        State.Kron(lhs, rhs) => true
        _ => false
    end
end

function Tree.Print.is_postfix(node::State.Type)
    @match node begin
        State.Annotate(expr) => true
        _ => false
    end
end

function Tree.Print.precedence(node::State.Type)
    @match node begin
        State.Variable(_) => 100
        State.Zero => 100
        State.Eigen(_, _) => 100
        State.Product(_) => 100
        State.Kron(lhs, rhs) => 1
        State.Add(_) => Base.operator_precedence(:+)
        _ => 0
    end
end

function Tree.Print.use_custom_print(node::State.Type)
    return isa_variant(node, State.Add)
end

function Tree.Print.custom_inline_print(io::IO, node::State.Type)
    @match node begin
        State.Add(terms) => Tree.Print.Add()(io, terms)
    end
end

function Tree.Print.should_print_annotation(node::State.Type)
    @match variant_type(node) begin
        State.Add => true
        _ => false
    end
end

function Tree.Print.annotations(node::State.Type)
    @match node begin
        State.Add(terms) => collect(Scalar.Type, values(terms))
        _ => Scalar.Type[]
    end
end

function braket(f, io::IO)
    is_ket = get(io, :ket, true)
    if is_ket
        print(io, "|")
    else
        print(io, "⟨")
    end

    f()

    if is_ket
        print(io, "⟩")
    else
        print(io, "|")
    end
end
