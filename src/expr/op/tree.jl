Base.show(io::IO, node::Op.Type) = Tree.Print.inline(io, node)
Base.show(io::IO, ::MIME"text/plain", node::Op.Type) = Tree.Print.text(io, node)

function Tree.children(node::Op.Type)
    @match node begin
        Op.Add(terms) => collect(Op.Type, keys(terms))
        Op.Mul(lhs, rhs) => [lhs, rhs]
        Op.Kron(lhs, rhs) => [lhs, rhs]
        Op.Comm(base, op, pow) => [base, op]
        Op.AComm(base, op, pow) => [base, op]
        Op.Pow(base, exp) => [base]
        Op.KronPow(base, exp) => [base]
        Op.Adjoint(op) => [op]
        Op.Subscript(op, _) => [op]
        Op.Sum(_, _, term) => [term]
        Op.Prod(_, _, term) => [term]
        Op.Exp(op) => [op]
        Op.Log(op) => [op]
        Op.Inv(op) => [op]
        Op.Sqrt(op) => [op]
        Op.Transpose(op) => [op]
        Op.Annotate(expr) => [expr]
        _ => Op.Type[]
    end
end

function Tree.n_children(node::Op.Type)
    @match node begin
        Op.Add(terms) => length(terms)
        Op.Mul(lhs, rhs) => 2
        Op.Kron(lhs, rhs) => 2
        Op.Comm(base, op, pow) => 2
        Op.AComm(base, op, pow) => 2
        Op.Pow(base, exp) => 1
        Op.KronPow(base, exp) => 1
        Op.Adjoint(op) => 1
        Op.Subscript(op, _) => 1
        Op.Sum(_, _, term) => 1
        Op.Prod(_, _, term) => 1
        Op.Exp(op) => 1
        Op.Log(op) => 1
        Op.Inv(op) => 1
        Op.Sqrt(op) => 1
        Op.Transpose(op) => 1
        Op.Annotate(expr) => 1
        _ => Op.Type[]
    end
end

function Tree.map_children(f, node::Op.Type)
    @match node begin
        Op.Add(terms) => Op.Add(Tree.map_ac_set(f, +, terms))
        Op.Mul(lhs, rhs) => Op.Mul(f(lhs), f(rhs))
        Op.Kron(lhs, rhs) => Op.Kron(f(lhs), f(rhs))
        Op.Comm(base, op, pow) => Op.Comm(f(base), f(op), pow)
        Op.AComm(base, op, pow) => Op.AComm(f(base), f(op), pow)
        Op.Pow(base, exp) => Op.Pow(f(base), exp)
        Op.KronPow(base, exp) => Op.KronPow(f(base), exp)
        Op.Adjoint(op) => Op.Adjoint(f(op))
        Op.Subscript(op, idx) => Op.Subscript(f(op), idx)
        Op.Sum(region, indices, term) => Op.Sum(region, indices, f(term))
        Op.Prod(region, indices, term) => Op.Prod(region, indices, f(term))
        Op.Exp(op) => Op.Exp(f(op))
        Op.Log(op) => Op.Log(f(op))
        Op.Inv(op) => Op.Inv(f(op))
        Op.Sqrt(op) => Op.Sqrt(f(op))
        Op.Transpose(op) => Op.Transpose(f(op))
        Op.Annotate(expr) => Op.Annotate(f(expr))
        _ => node
    end
end

function Tree.threaded_map_children(f, node::Op.Type)
    @match node begin
        Op.Add(terms) => Op.Add(Tree.threaded_map_ac_set(f, terms))
        _ => Tree.map_children(f, node)
    end
end

function Tree.is_leaf(node::Op.Type)
    @match variant_type(node) begin
        Op.Add => false
        Op.Mul => false
        Op.Kron => false
        Op.Comm => false
        Op.AComm => false
        Op.Pow => false
        Op.KronPow => false
        Op.Adjoint => false
        Op.Subscript => false
        Op.Sum => false
        Op.Prod => false
        Op.Exp => false
        Op.Log => false
        Op.Inv => false
        Op.Sqrt => false
        Op.Transpose => false
        Op.Annotate => false
        _ => true
    end
end

function Tree.Print.print_node(io::IO, node::Op.Type)
    @match node begin
        Op.Zero => print(io, "O")
        Op.Wildcard => print(io, "_")
        Op.Match(name) => print(io, "\$", name)
        Op.Annotate(op, basis) => printstyled(io, "%", basis; color=:light_black)

        Op.Constant(value) => print(io, value)
        Op.Variable(; name, id) => Tree.Print.print_variable(io, name, id)

        Op.Mul(lhs, rhs) => print(io, "*")
        Op.Kron(lhs, rhs) => print(io, "⊗")
        Op.Pow(base, exp) => begin
            print(io, "^")
            Tree.Print.inline(io, exp)
        end
        Op.KronPow(base, exp) => begin
            print(io, "^⊗")
            Tree.Print.inline(io, exp)
        end
        Op.Exp(op) => print(io, "exp")
        Op.Log(op) => print(io, "log")
        Op.Inv(op) => print(io, "inv")
        Op.Sqrt(op) => print(io, "sqrt")

        Op.Comm(base, op, pow) => if isone(pow)
            print(io, "ad")
        else
            print(io, "ad^{")
            Tree.Print.inline(io, pow)
            print(io, "}")
        end

        # NOTE: ehhh, there is no standard notation
        # for Jordan product or anti-commutator  ---- ChatGPT & Bard
        #
        # let's use `ap` for "adjoint plus", make it easier to print
        #                                   ---- Issac Newton
        Op.AComm(base, op, pow) => if isone(pow)
            print(io, "ap")
        else
            print(io, "ap^{")
            Tree.Print.inline(io, pow)
            print(io, "}")
        end
        Op.Outer(lhs, rhs) => begin
            print(io, "|")
            Tree.Print.inline(io, lhs)
            print(io, "⟩⟨")
            Tree.Print.inline(io, rhs)
            print(io, "|")
        end

        # postfix op
        Op.Adjoint(op) => print(io, "†")
        Op.Transpose(op) => print(io, "ᵀ")
        Op.Subscript(op, inds) => begin
            print(io, "[")
            Tree.Print.inline_list(IOContext(io, :precedence => 0), inds)
            print(io, "]")
        end
        _ => print(io, variant_name(node))

        # # these are using custom printing
        # # Op.Add(coeffs, terms) => print(io, "+")
        # _ => error("unhandled node: ", variant_type(node))
    end
end

function Tree.Print.is_infix(node::Op.Type)
    @match node begin
        Op.Mul(_) => true
        Op.Kron(_) => true
        _ => false
    end
end

function Tree.Print.is_postfix(node::Op.Type)
    @match node begin
        Op.Pow(_) => true
        Op.KronPow(_) => true
        Op.Adjoint(_) => true
        Op.Transpose(_) => true
        Op.Subscript(_) => true
        Op.Annotate(_) => true
        _ => false
    end
end

function Tree.Print.use_custom_print(node::Op.Type)
    @match variant_type(node) begin
        Op.Add => true
        Op.Sum => true
        Op.Prod => true
        Op.Comm => true
        Op.AComm => true
        _ => false
    end
end

function Tree.Print.custom_inline_print(io::IO, node::Op.Type)
    @match node begin
        Op.Add(terms) => print_add(io, terms)
        Op.Sum(region, indices, term) => print_reduction(io, "∑", region, indices, term)
        Op.Prod(region, indices, term) => print_reduction(io, "∏", region, indices, term)
        Op.Comm(_) => print_jordan_lie(io, node)
        Op.AComm(_) => print_jordan_lie(io, node)

        _ => error("unhandled node: ", variant_type(node))
    end
end

function print_jordan_lie(io::IO, node::Op.Type)
    isa_variant(node, Op.Comm) || isa_variant(node, Op.AComm) || error("invalid node")
    Tree.Print.print_node(io, node)
    print(io, "_{")
    Tree.Print.inline(node.base)
    print(io, "}(")
    Tree.Print.inline(node.pow)
    return print(io, ")")
end

function print_reduction(io::IO, op::String, region, indices, term)
    print(io, "(", op, "_{")
    print(io, indices, "∈")
    print(io, region) # TODO: switch to region's inline_print
    # Tree.Print.inline_print(io, region)
    print(io, "} ")
    Tree.Print.inline(io, term)
    return print(io, ")")
end

function Tree.Print.precedence(node::Op.Type)
    @match variant_type(node) begin
        if Tree.is_leaf(node) end => 100
        Op.Add => Base.operator_precedence(:+)
        Op.Mul => Base.operator_precedence(:*)
        Op.Kron => Base.operator_precedence(:⊗)
        Op.Pow => Base.operator_precedence(:^)
        Op.KronPow => Base.operator_precedence(:^)
        _ => 0
    end
end

function Tree.Print.should_print_annotation(node::Op.Type)
    @match variant_type(node) begin
        Op.Add => true
        _ => false
    end
end

function Tree.Print.annotations(node::Op.Type)
    @match node begin
        Op.Add(terms) => collect(Scalar.Type, values(terms))
        _ => Scalar.Type[]
    end
end

function Tree.Print.print_annotation(io::IO, coeff::Scalar.Type)
    @match coeff begin
        Scalar.Constant(Num.One) => return nothing
        Scalar.Neg(Num.One) => print(io, "-")
        Scalar.Constant(Num.Real(-1)) => print(io, "-")
        _ => begin
            Tree.Print.inline(io, coeff)
            print(io, " * ")
        end
    end
end

function Tree.Print.print_meta(io::IO, node::Op.Type)
    @match node begin
        # TODO: switch this to region inline_print
        Op.Sum(region, indices) => begin
            join(io, indices, ", ")
            print(io, " ∈ ", region)
        end
        Op.Prod(region, indices) => begin
            join(io, indices, ", ")
            print(io, " ∈ ", region)
        end
        _ => nothing
    end
end

function print_add(io::IO, terms::Dict{Op.Type,Scalar.Type})
    parent_pred = get(io, :precedence, 0)
    node_pred = Tree.Print.precedence(:+)
    parent_pred > node_pred && print(io, "(")

    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        if !isone(coeff)
            Tree.Print.inline(io, coeff)
            print(io, "*")
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:*))
        else
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:+))
        end
        Tree.Print.inline(sub_io, term)
        if idx < length(terms)
            print(io, "+")
        end
    end

    parent_pred > node_pred && print(io, ")")
    return nothing
end
