function Tree.children(node::Scalar.Type)
    @match node begin
        Scalar.Neg(x) => [x]
        Scalar.Abs(x) => [x]
        Scalar.Exp(x) => [x]
        Scalar.Log(x) => [x]
        Scalar.Sqrt(x) => [x]
        Scalar.Sum(coeffs, terms) => collect(Scalar.Type, keys(terms))
        Scalar.Prod(coeffs, terms) => collect(Scalar.Type, keys(terms))
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
        Scalar.Sum(coeffs, terms) => length(terms)
        Scalar.Prod(coeffs, terms) => length(terms)
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
        Scalar.Sum(coeffs, terms) => Scalar.Sum(coeffs, Tree.map_ac_set(f, +, terms))
        Scalar.Prod(coeffs, terms) => Scalar.Prod(coeffs, Tree.map_ac_set(f, *, terms))
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
        Scalar.Sum(coeffs, terms) =>
            Scalar.Sum(coeffs, Tree.threaded_map_ac_set(f, +, terms))
        Scalar.Prod(coeffs, terms) =>
            Scalar.Prod(coeffs, Tree.threaded_map_ac_set(f, *, terms))
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
        Scalar.Variable(name, id) => if id > 0 # SSA var
            print(io, "%", name)
        else
            print(io, name)
        end

        Scalar.Neg(x) => print(io, "-")
        Scalar.Abs(x) => print(io, "abs")
        Scalar.Exp(x) => print(io, "exp")
        Scalar.Log(x) => print(io, "log")
        Scalar.Sqrt(x) => print(io, "sqrt")

        Scalar.Sum(coeffs, terms) => print(io, "+")
        Scalar.Prod(coeffs, terms) => print(io, "*")
        Scalar.Pow(base, exp) => print(io, "^")
        Scalar.Div(num, den) => print(io, "/")

        Scalar.JuliaCall(mod, name, args) => print(io, "$mod.$name")
        Scalar.RoutineCall(name, args) => print(io, name)

        Scalar.Partial(expr, var) => print(io, "∂")
        Scalar.Derivative(expr, var) => print(io, "d")

        Scalar.Annotate(expr, domain, unit) => printstyled(io, "*", unit, color=:light_black)
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
    return isa_variant(node, Scalar.Sum) ||
           isa_variant(node, Scalar.Prod)
end

function Tree.custom_inline_print(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Sum(coeffs, terms) => print_sum(io, coeffs, terms)
        Scalar.Prod(coeffs, terms) => print_prod(io, coeffs, terms)
    end
end

function Tree.precedence(node::Scalar.Type)
    @match node begin
        Scalar.Sum(_...) => Base.operator_precedence(:+)
        Scalar.Prod(_...) => Base.operator_precedence(:*)
        Scalar.Pow(_...) => Base.operator_precedence(:^)
        Scalar.Div(_...) => Base.operator_precedence(:/)
        _ => 0
    end
end

function Tree.print_meta(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Sum(coeffs) => if !iszero(coeffs)
            Tree.inline_print(io, coeffs)
        end
        Scalar.Prod(coeffs) => if !isone(coeffs)
            Tree.inline_print(io, coeffs)
        end
        _ => nothing
    end
end

function print_sum(io::IO, coeffs::Num.Type, terms::Dict{Scalar.Type,Num.Type})
    parent_pred = get(io, :precedence, 0)
    node_pred = Tree.precedence(:+)
    parent_pred > node_pred && print(io, "(")

    @match coeffs begin
        Num.Zero => nothing
        _ => begin
            Tree.inline_print(io, coeffs)
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

function print_prod(io::IO, coeffs::Num.Type, terms::Dict{Scalar.Type,Num.Type})
    parent_pred = get(io, :precedence, 0)
    node_pred = Tree.precedence(:+)
    parent_pred > node_pred && print(io, "(")

    @match coeffs begin
        Num.Zero => nothing
        _ => begin
            Tree.inline_print(io, coeffs)
            if !isempty(terms)
                print(io, "*")
            end
        end
    end

    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        if !isone(coeff)
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:^))
            Tree.inline_print(sub_io, term)
            print(io, "^")
            Tree.inline_print(io, coeff)
        else
            sub_io = IOContext(io, :precedence => Base.operator_precedence(:*))
            Tree.inline_print(sub_io, term)
        end

        if idx < length(terms)
            print(io, "*")
        end
    end
    parent_pred > node_pred && print(io, ")")
    return nothing
end
