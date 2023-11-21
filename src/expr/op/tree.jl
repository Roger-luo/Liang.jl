function Tree.children(node::Op.Type)
    @match node begin
        Op.Add(_, terms) => collect(Op.Type, keys(terms))
        Op.Mul(lhs, rhs) => [lhs, rhs]
        Op.Kron(lhs, rhs) => [lhs, rhs]
        Op.Comm(base, op, pow) => [base, op]
        Op.AComm(base, op, pow) => [base, op]
        Op.Pow(base, exp) => [base]
        Op.KronPow(base, exp) => [base]
        Op.Adjoint(op) => [op]
        Op.Subscript(op, _) => [op]
        Op.Sum(_, term) => [term]
        Op.Prod(_, term) => [term]
        Op.Exp(op) => [op]
        Op.Log(op) => [op]
        Op.Tr(op) => [op]
        Op.Det(op) => [op]
        Op.Inv(op) => [op]
        Op.Sqrt(op) => [op]
        Op.Transpose(op) => [op]
        Op.Annotate(expr) => [expr]
        _ => Op.Type[]
    end
end

function Tree.n_children(node::Op.Type)
    @match node begin
        Op.Add(_, terms) => length(terms)
        Op.Mul(lhs, rhs) => 2
        Op.Kron(lhs, rhs) => 2
        Op.Comm(base, op, pow) => 2
        Op.AComm(base, op, pow) => 2
        Op.Pow(base, exp) => 1
        Op.KronPow(base, exp) => 1
        Op.Adjoint(op) => 1
        Op.Subscript(op, _) => 1
        Op.Sum(_, term) => 1
        Op.Prod(_, term) => 1
        Op.Exp(op) => 1
        Op.Log(op) => 1
        Op.Tr(op) => 1
        Op.Det(op) => 1
        Op.Inv(op) => 1
        Op.Sqrt(op) => 1
        Op.Transpose(op) => 1
        Op.Annotate(expr) => 1
        _ => Op.Type[]
    end
end

function Tree.map_children(f, node::Op.Type)
    @match node begin
        Op.Add(coeffs, terms) => Op.Add(coeffs, Tree.map_ac_set(f, +, terms))
        Op.Mul(lhs, rhs) => Op.Mul(f(lhs), f(rhs))
        Op.Kron(lhs, rhs) => Op.Kron(f(lhs), f(rhs))
        Op.Comm(base, op, pow) => Op.Comm(f(base), f(op), pow)
        Op.AComm(base, op, pow) => Op.AComm(f(base), f(op), pow)
        Op.Pow(base, exp) => Op.Pow(f(base), exp)
        Op.KronPow(base, exp) => Op.KronPow(f(base), exp)
        Op.Adjoint(op) => Op.Adjoint(f(op))
        Op.Subscript(op, idx) => Op.Subscript(f(op), idx)
        Op.Sum(region, term) => Op.Sum(region, f(term))
        Op.Prod(region, term) => Op.Prod(region, f(term))
        Op.Exp(op) => Op.Exp(f(op))
        Op.Log(op) => Op.Log(f(op))
        Op.Tr(op) => Op.Tr(f(op))
        Op.Det(op) => Op.Det(f(op))
        Op.Inv(op) => Op.Inv(f(op))
        Op.Sqrt(op) => Op.Sqrt(f(op))
        Op.Transpose(op) => Op.Transpose(f(op))
        Op.Annotate(expr) => Op.Annotate(f(expr))
        _ => node
    end
end

function Tree.threaded_map_children(f, node::Op.Type)
    @match node begin
        Op.Add(coeffs, terms) => Op.Add(coeffs, Tree.threaded_map_ac_set(f, +, terms))
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
        Op.Tr => false
        Op.Det => false
        Op.Inv => false
        Op.Sqrt => false
        Op.Transpose => false
        Op.Annotate => false
        _ => true
    end
end

function Tree.print_node(io::IO, node::Op.Type)
    @match node begin
        Op.Wildcard => print(io, "_")
        Op.Match(name) => print(io, "\$", name)
        Op.I => print(io, "I")
        Op.X => print(io, "X")
        Op.Y => print(io, "Y")
        Op.Z => print(io, "Z")
        Op.S => print(io, "S")
        Op.H => print(io, "H")
        Op.T => print(io, "T")
        Op.SWAP => print(io, "SWAP")
        Op.Annotate(op, basis) => printstyled(io, " %", basis)

        Op.Constant(value) => print(io, value)
        Op.Variable(name, id) => if id > 0 # SSA var
            print(io, "%", name)
        else
            print(io, name)
        end

        Op.Mul(lhs, rhs) => print(io, "*")
        Op.Kron(lhs, rhs) => print(io, "⊗")
        Op.Pow(base, exp) => print(io, "^")
        Op.KronPow(base, exp) => print(io, "^⊗")
        Op.Exp(op) => print(io, "exp")
        Op.Log(op) => print(io, "log")
        Op.Tr(op) => print(io, "tr")
        Op.Det(op) => print(io, "det")
        Op.Inv(op) => print(io, "inv")
        Op.Sqrt(op) => print(io, "sqrt")

        Op.Comm(base, op, pow) => if isone(pow)
            print(io, "ad_{")
            Tree.inline_print(io, base)
            print(io, "}")
        else
            print(io, "ad_{")
            Tree.inline_print(io, base)
            print(io, "}^{")
            Tree.inline_print(io, pow)
            print(io, "}")
        end
        Op.AComm(base, op, pow) => if isone(pow)
            print(io, "ad_{")
            Tree.inline_print(io, base)
            print(io, ",+}")
        else
            print(io, "ad_{")
            Tree.inline_print(io, base)
            print(io, ",+}^{")
            Tree.inline_print(io, pow)
            print(io, "}")
        end
        Op.Outer(lhs, rhs) => begin
            print(io, "|")
            Tree.inline_print(io, lhs)
            print(io, "⟩⟨")
            Tree.inline_print(io, rhs)
            print(io, "|")
        end

        # postfix op
        Op.Adjoint(op) => print(io, "†")
        Op.Transpose(op) => print(io, "ᵀ")
        Op.Subscript(op, inds) => begin
            print(io, "[")
            for (i, ind) in enumerate(inds)
                if i > 1
                    print(io, ", ")
                end
                Tree.inline_print(IOContext(io, :precedence => 0), ind)
            end
            print(io, "]")
        end

        # these are using custom printing
        # Op.Add(coeffs, terms) => print(io, "+")
        _ => error("unhandled node: ", variant_type(node))
    end
end

function Tree.is_infix(node::Op.Type)
    @match node begin
        Op.Mul(_) => true
        Op.Kron(_) => true
        Op.Pow(_) => true
        Op.KronPow(_) => true
        _ => false
    end
end

function Tree.is_postfix(node::Op.Type)
    @match node begin
        Op.Adjoint(_) => true
        Op.Transpose(_) => true
        Op.Subscript(_) => true
        Op.Annotate(_) => true
        _ => false
    end
end

function Tree.use_custom_print(node::Op.Type)
    @match variant_type(node) begin
        Op.Add => true
        Op.Sum => true
        Op.Prod => true
        _ => false
    end
end

function Tree.custom_inline_print(io::IO, node::Op.Type)
    @match node begin
        Op.Add(coeffs, terms) => print_add(io, coeffs, terms)
        Op.Sum(region, term) => begin
            print(io, "(∑_{")
            print(io, region) # TODO: switch to region's inline_print
            # Tree.inline_print(io, region)
            print(io, "} ")
            Tree.inline_print(io, term)
            print(io, ")")
        end

        Op.Prod(region, term) => begin
            print(io, "(∏_{")
            print(io, region) # TODO: switch to region's inline_print
            # Tree.inline_print(io, region)
            print(io, "} ")
            Tree.inline_print(io, term)
            print(io, ")")
        end

        Op.Annotate(op, basis) => begin
            Tree.inline_print(io, op)
            Tree.print_node(io, basis)
        end

        _ => error("unhandled node: ", variant_type(node))
    end
end

function Tree.precedence(node::Op.Type)
    @match variant_type(node) begin
        Op.Add => Base.operator_precedence(:+)
        Op.Mul => Base.operator_precedence(:*)
        Op.Kron => Base.operator_precedence(:⊗)
        Op.Pow => Base.operator_precedence(:^)
        Op.KronPow => Base.operator_precedence(:^)
        _ => 0
    end
end

function print_add(io::IO, coeffs::Scalar.Type, terms::Dict{Op.Type,Scalar.Type})
    parent_pred = get(io, :precedence, 0)
    node_pred = Tree.precedence(:+)
    parent_pred > node_pred && print(io, "(")

    @match coeffs begin
        Scalar.Constant(Num.Zero) => nothing

        _ => begin
            Tree.inline_print(io, coeffs)
            print(io, "*I")
            if !isempty(terms)
                print(io, "+")
            end
        end
    end

    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        if !isone(coeff)
            Tree.inline_print(io, coeff)
            print(io, "*")
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:*))
        else
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:+))
        end
        Tree.inline_print(sub_io, term)
        if idx < length(terms)
            print(io, "+")
        end
    end

    parent_pred > node_pred && print(io, ")")
    return nothing
end
