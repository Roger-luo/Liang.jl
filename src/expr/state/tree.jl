Base.show(io::IO, node::State.Type) = Tree.inline_print(io, node)
Base.show(io::IO, ::MIME"text/plain", node::State.Type) = Tree.text_print(io, node)

function Tree.children(node::State.Type)
    @match node begin
        State.Kron(lhs, rhs) => [lhs, rhs]
        State.Add(terms) => collect(State.Type, keys(terms))
        State.Annotate(expr) => [expr]
        _ => State.Type[]
    end
end

function Tree.n_children(node::State.Type)
    @match node begin
        State.Kron(lhs, rhs) => 2
        State.Add(terms) => length(terms)
        State.Annotate(expr) => 1
        _ => State.Type[]
    end
end

function Tree.map_children(f, node::State.Type)
    @match node begin
        State.Kron(lhs, rhs) => State.Kron(f(lhs), f(rhs))
        State.Add(terms) => State.Add(Tree.map_ac_set(f, +, terms))
        State.Annotate(expr) => State.Annotate(f(expr))
        _ => node
    end
end

function Tree.threaded_map_children(f, node::State.Type)
    @match node begin
        State.Kron(lhs, rhs) => State.Kron(f(lhs), f(rhs))
        State.Add(terms) => State.Add(Tree.threaded_map_ac_set(f, +, terms))
        State.Annotate(expr) => State.Annotate(f(expr))
        _ => node
    end
end

function Tree.is_leaf(node::State.Type)
    return iszero(Tree.n_children(node))
end

function Tree.print_node(io::IO, node::State.Type)
    @match node begin
        State.Wildcard => print(io, "_")
        State.Match(name) => print(io, "\$", name)
        State.Variable(; name, id) => braket(io) do
            Tree.print_variable(io, name, id)
        end
        State.Zero => print(io, "0")
        State.Eigen(op::Op.Type, n) => begin
            print(io, "Eigen(")
            Tree.inline_print(io, op)
            print(io, ", ", n, ")")
        end
        State.Product(config) => braket(io) do
            Tree.print_list(IOContext(io, :precedence => 0), config)
        end
        State.Kron(lhs, rhs) => print(io, "⊗")
        State.Add(terms) => print(io, "+")
        State.Annotate(expr) => print(io, "%")
    end
end

function Tree.is_infix(node::State.Type)
    @match node begin
        State.Kron(lhs, rhs) => true
        _ => false
    end
end

function Tree.is_postfix(node::State.Type)
    @match node begin
        State.Annotate(expr) => true
        _ => false
    end
end

function Tree.precedence(node::State.Type)
    @match node begin
        State.Wildcard => 100
        State.Match(_) => 100
        State.Variable(_) => 100
        State.Zero => 100
        State.Eigen(_, _) => 100
        State.Product(_) => 100
        State.Kron(lhs, rhs) => 1
        _ => 0
    end
end

function Tree.use_custom_print(node::State.Type)
    return isa_variant(node, State.Add)
end

function Tree.custom_inline_print(io::IO, node::State.Type)
    @match node begin
        State.Add(terms) => Tree.print_add(io, terms)
    end
end

function Tree.should_print_annotation(node::State.Type)
    @match variant_type(node) begin
        State.Add => true
        _ => false
    end
end

function Tree.annotations(node::State.Type)
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
