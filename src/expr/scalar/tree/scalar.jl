# well we don't really need printing to be type stable
function Tree.Print.children(node::Scalar.Type)::Vector{Union{Op.Type,Scalar.Type}}
    @match node begin
        Scalar.Tr(op) => [op]
        Scalar.Det(op) => [op]
        _ => Tree.children(node)
    end
end

function Tree.Print.n_children(node::Scalar.Type)::Int
    @match node begin
        Scalar.Tr(op) => 1
        Scalar.Det(op) => 1
        _ => Tree.n_children(node)
    end
end

function Tree.Print.print_node(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Wildcard => print(io, "_")
        Scalar.Match(name) => print(io, "\$", name)
        Scalar.Constant(x) => print(io, x)
        Scalar.Pi => print(io, "π")
        Scalar.Euler => print(io, "ℯ")
        Scalar.Hbar => print(io, "ℏ")
        Scalar.Variable(name, id) => Tree.Print.print_variable(io, name, id)
        Scalar.Subscript(ref, indices) => begin
            print(io, ref)
            print(io, "[")
            Tree.Print.inline_list(IOContext(io, :precedence => 0), indices)
            print(io, "]")
        end

        Scalar.Neg(x) => print(io, "-")
        Scalar.Conj(x) => print(io, "conj")
        Scalar.Abs(x) => print(io, "abs")
        Scalar.Exp(x) => print(io, "exp")
        Scalar.Log(x) => print(io, "log")
        Scalar.Sqrt(x) => print(io, "sqrt")
        Scalar.Tr(x) => print(io, "tr")
        Scalar.Det(x) => print(io, "det")

        Scalar.Add(coeffs, terms) => print(io, "+")
        Scalar.Mul(coeffs, terms) => print(io, "*")
        Scalar.Pow(base, exp) => print(io, "^")
        Scalar.Div(num, den) => print(io, "/")

        Scalar.JuliaCall(mod, name, args) => print(io, "$mod.$name")
        Scalar.RoutineCall(name, args) => print(io, name)

        Scalar.Partial(expr, var) => print(io, "∂")
        Scalar.Derivative(expr, var) => print(io, "d")

        Scalar.Domain(expr, domain) => print(io, "domain") # don't show in inline print
        Scalar.Unit(expr, unit) => printstyled(io, "*", dimension(unit); color=:light_black)
    end
end

function Tree.Print.is_prefix(node::Scalar.Type)::Bool
    @match node begin
        Scalar.Neg(x) => true
        _ => false
    end
end

function Tree.Print.is_infix(node::Scalar.Type)::Bool
    @match node begin
        Scalar.Pow(base, exp) => true
        Scalar.Div(num, den) => true
        _ => false
    end
end

function Tree.Print.is_postfix(node::Scalar.Type)::Bool
    return isa_variant(node, Scalar.Unit)
end

function Tree.Print.use_custom_print(node::Scalar.Type)::Bool
    @match variant_type(node) begin
        Scalar.Add => true
        Scalar.Mul => true
        Scalar.Tr => true
        Scalar.Det => true
        Scalar.Domain => true
        _ => false
    end
end

function Tree.Print.custom_inline_print(io::IO, node::Scalar.Type)
    @match node begin
        # skip domain annotation
        Scalar.Domain(x) => Tree.Print.inline(io, x)
        Scalar.Tr(op) || Scalar.Det(op) => begin
            Tree.Print.print_node(io, node)
            print(io, "(")
            Tree.Print.inline(io, op)
            print(io, ")")
        end
        Scalar.Add(coeffs, terms) => begin
            @match coeffs begin
                Num.Zero => nothing
                _ => begin
                    print(io, coeffs)
                    if !isempty(terms)
                        print(io, "+")
                    end
                end
            end
            Tree.Print.print_add(io, terms)
        end
        Scalar.Mul(coeffs, terms) => begin
            @match coeffs begin
                Num.Zero => nothing
                Num.One => nothing
                _ => begin
                    print(io, coeffs)
                    if !isempty(terms)
                        print(io, "*")
                    end
                end
            end
            Tree.Print.print_mul(io, terms)
        end
    end
end

function Tree.Print.precedence(node::Scalar.Type)::Int
    @match node begin
        Scalar.Constant(x) => x < 0 ? 0 : 100
        if Tree.is_leaf(node)
        end => 100
        Scalar.Add(_...) => Base.operator_precedence(:+)
        Scalar.Mul(_...) => Base.operator_precedence(:*)
        Scalar.Pow(_...) => Base.operator_precedence(:^)
        Scalar.Div(_...) => Base.operator_precedence(:/)
        _ => 0
    end
end

function Tree.Print.print_meta(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Add(coeffs) => if !iszero(coeffs)
            print(io, coeffs)
        end
        Scalar.Mul(coeffs) => if !isone(coeffs)
            print(io, coeffs)
        end
        Scalar.Domain(expr, domain) => print(io, "[$domain]")
        _ => nothing
    end
end
