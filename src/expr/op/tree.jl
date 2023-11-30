Base.show(io::IO, node::Op.Type) = Tree.Print.inline(io, node)
Base.show(io::IO, ::MIME"text/plain", node::Op.Type) = Tree.Print.text(io, node)

function Tree.Print.print_node(io::IO, node::Op.Type)
    @match node begin
        Op.Zero => print(io, "O")
        Op.Annotate(op, basis) => printstyled(io, "%", basis; color=:light_black)

        Op.Constant(value) => print(io, value)
        Op.Variable(x) => print(io, x)

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
        Op.TimeOrdered(op, var) => print(io, "T_{", var, "}")
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
        Op.Add(terms) => Tree.Print.Add()(io, terms)
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
        if Tree.is_leaf(node)
        end => 100
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
