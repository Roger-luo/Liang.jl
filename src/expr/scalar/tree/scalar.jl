function Tree.children(node::Scalar.Type)
    @match node begin
        Scalar.Neg(x) => [x]
        Scalar.Abs(x) => [x]
        Scalar.Exp(x) => [x]
        Scalar.Log(x) => [x]
        Scalar.Sqrt(x) => [x]
        Scalar.Add(coeffs, terms) => collect(Scalar.Type, keys(terms))
        Scalar.Mul(coeffs, terms) => collect(Scalar.Type, keys(terms))
        Scalar.Pow(base, exp) => [base, exp]
        Scalar.Div(num, den) => [num, den]
        Scalar.JuliaCall(mod, name, args) => args
        Scalar.RoutineCall(name, args) => args
        Scalar.Partial(expr, var) => [expr, var]
        Scalar.Derivative(expr, var) => [expr, var]
        _ => Scalar.Type[]
    end
end

function Tree.n_children(node::Scalar.Type)
    @match node begin
        Scalar.Neg(x) => 1
        Scalar.Abs(x) => 1
        Scalar.Exp(x) => 1
        Scalar.Log(x) => 1
        Scalar.Sqrt(x) => 1
        Scalar.Add(coeffs, terms) => length(terms)
        Scalar.Mul(coeffs, terms) => length(terms)
        Scalar.Pow(base, exp) => 2
        Scalar.Div(num, den) => 2
        Scalar.JuliaCall(mod, name, args) => length(args)
        Scalar.RoutineCall(name, args) => length(args)
        Scalar.Partial(expr, var) => 2
        Scalar.Derivative(expr, var) => 2
        _ => 0
    end
end

function Tree.map_children(f, node::Scalar.Type)
    @match node begin
        Scalar.Neg(x) => Scalar.Neg(f(x))
        Scalar.Abs(x) => Scalar.Abs(f(x))
        Scalar.Exp(x) => Scalar.Exp(f(x))
        Scalar.Log(x) => Scalar.Log(f(x))
        Scalar.Sqrt(x) => Scalar.Sqrt(f(x))
        Scalar.Add(coeffs, terms) => Scalar.Add(coeffs, Tree.map_ac_set(f, +, terms))
        Scalar.Mul(coeffs, terms) => Scalar.Mul(coeffs, Tree.map_ac_set(f, *, terms))
        Scalar.Pow(base, exp) => Scalar.Pow(f(base), f(exp))
        Scalar.Div(num, den) => Scalar.Div(f(num), f(den))
        Scalar.JuliaCall(mod, name, args) => Scalar.JuliaCall(mod, name, map(f, args))
        Scalar.RoutineCall(name, args) => Scalar.RoutineCall(name, map(f, args))
        Scalar.Partial(expr, var) => Scalar.Partial(f(expr), f(var))
        Scalar.Derivative(expr, var) => Scalar.Derivative(f(expr), f(var))
        Scalar.Annotate(expr, domain, unit) => Scalar.Annotate(f(expr), domain, unit)
    end
end

function Tree.threaded_map_children(f, node::Scalar.Type)
    @match node begin
        Scalar.Neg(x) => Scalar.Neg(f(x))
        Scalar.Abs(x) => Scalar.Abs(f(x))
        Scalar.Exp(x) => Scalar.Exp(f(x))
        Scalar.Log(x) => Scalar.Log(f(x))
        Scalar.Sqrt(x) => Scalar.Sqrt(f(x))
        Scalar.Add(coeffs, terms) =>
            Scalar.Add(coeffs, Tree.threaded_map_ac_set(f, +, terms))
        Scalar.Mul(coeffs, terms) =>
            Scalar.Mul(coeffs, Tree.threaded_map_ac_set(f, *, terms))
        Scalar.Pow(base, exp) => Scalar.Pow(f(base), f(exp))
        Scalar.Div(num, den) => Scalar.Div(f(num), f(den))
        Scalar.JuliaCall(mod, name, args) =>
            Scalar.JuliaCall(mod, name, tcollect(Map(f)(args)))
        Scalar.RoutineCall(name, args) => Scalar.RoutineCall(name, tcollect(Map(f)(args)))
        Scalar.Partial(expr, var) => Scalar.Partial(f(expr), f(var))
        Scalar.Derivative(expr, var) => Scalar.Derivative(f(expr), f(var))
        Scalar.Annotate(expr, domain, unit) => Scalar.Annotate(f(expr), domain, unit)
    end
end

function Tree.is_leaf(node::Scalar.Type)
    @match node begin
        Scalar.Wildcard => true
        Scalar.Match(name) => true
        Scalar.Constant(x) => true
        Scalar.Variable(name, id) => true
        Scalar.Subscript(ref, indices) => true
        Scalar.Pi => true
        Scalar.Euler => true
        Scalar.Hbar => true
        _ => false
    end
end

function Tree.print_node(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Wildcard => print(io, "_")
        Scalar.Match(name) => print(io, "\$", name)
        Scalar.Constant(x) => Tree.inline_print(io, x)
        Scalar.Pi => print(io, "π")
        Scalar.Euler => print(io, "ℯ")
        Scalar.Hbar => print(io, "ℏ")
        Scalar.Variable(name, id) => Tree.print_variable(io, name, id)
        Scalar.Subscript(ref, indices) => begin
            print(io, ref)
            print(io, "[")
            Tree.print_list(IOContext(io, :precedence => 0), indices)
            print(io, "]")
        end

        Scalar.Neg(x) => print(io, "-")
        Scalar.Abs(x) => print(io, "abs")
        Scalar.Exp(x) => print(io, "exp")
        Scalar.Log(x) => print(io, "log")
        Scalar.Sqrt(x) => print(io, "sqrt")

        Scalar.Add(coeffs, terms) => print(io, "+")
        Scalar.Mul(coeffs, terms) => print(io, "*")
        Scalar.Pow(base, exp) => print(io, "^")
        Scalar.Div(num, den) => print(io, "/")

        Scalar.JuliaCall(mod, name, args) => print(io, "$mod.$name")
        Scalar.RoutineCall(name, args) => print(io, name)

        Scalar.Partial(expr, var) => print(io, "∂")
        Scalar.Derivative(expr, var) => print(io, "d")

        Scalar.Annotate(expr, domain, unit) =>
            printstyled(io, "*", unit; color=:light_black)
    end
end

function Tree.is_prefix(node::Scalar.Type)
    @match node begin
        Scalar.Neg(x) => true
        _ => false
    end
end

function Tree.is_infix(node::Scalar.Type)
    @match node begin
        Scalar.Pow(base, exp) => true
        Scalar.Div(num, den) => true
        _ => false
    end
end

function Tree.is_postfix(node::Scalar.Type)
    return isa_variant(node, Scalar.Annotate)
end

function Tree.use_custom_print(node::Scalar.Type)
    return isa_variant(node, Scalar.Add) || isa_variant(node, Scalar.Mul)
end

function Tree.custom_inline_print(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Add(coeffs, terms) => begin
            @match coeffs begin
                Num.Zero => nothing
                _ => begin
                    Tree.inline_print(io, coeffs)
                    if !isempty(terms)
                        print(io, "+")
                    end
                end
            end
            Tree.print_add(io, terms)
        end
        Scalar.Mul(coeffs, terms) => begin
            @match coeffs begin
                Num.Zero => nothing
                Num.One => nothing
                _ => begin
                    Tree.inline_print(io, coeffs)
                    if !isempty(terms)
                        print(io, "*")
                    end
                end
            end
            Tree.print_mul(io, terms)
        end
    end
end

function Tree.precedence(node::Scalar.Type)
    @match node begin
        Scalar.Constant(x) => x < 0 ? 0 : 100
        Scalar.Variable(_) => 100
        Scalar.Subscript(_) => 100
        Scalar.Pi => 100
        Scalar.Euler => 100
        Scalar.Hbar => 100
        Scalar.Wildcard => 100
        Scalar.Match(_) => 100
        Scalar.Add(_...) => Base.operator_precedence(:+)
        Scalar.Mul(_...) => Base.operator_precedence(:*)
        Scalar.Pow(_...) => Base.operator_precedence(:^)
        Scalar.Div(_...) => Base.operator_precedence(:/)
        _ => 0
    end
end

function Tree.print_meta(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Add(coeffs) => if !iszero(coeffs)
            Tree.inline_print(io, coeffs)
        end
        Scalar.Mul(coeffs) => if !isone(coeffs)
            Tree.inline_print(io, coeffs)
        end
        _ => nothing
    end
end
