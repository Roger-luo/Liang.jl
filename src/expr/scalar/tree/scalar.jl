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

function Tree.substitute(node::Scalar.Type, replace::Dict{Scalar.Type,Scalar.Type})
    @match node begin
        Scalar.Neg(x) => Scalar.Neg(get(replace, x, x))
        Scalar.Abs(x) => Scalar.Abs(get(replace, x, x))
        Scalar.Exp(x) => Scalar.Exp(get(replace, x, x))
        Scalar.Log(x) => Scalar.Log(get(replace, x, x))
        Scalar.Sqrt(x) => Scalar.Sqrt(get(replace, x, x))
        Scalar.Sum(coeffs, terms) => Scalar.Sum(coeffs, substitute_ac_set(terms, children))
        Scalar.Prod(coeffs, terms) =>
            Scalar.Prod(coeffs, substitute_ac_set(terms, children))
        Scalar.Pow(base, exp) =>
            Scalar.Pow(get(replace, base, base), get(replace, exp, exp))
        Scalar.Div(num, den) => Scalar.Div(get(replace, num, num), get(replace, den, den))
        Scalar.JuliaCall(mod, name, args) =>
            Scalar.JuliaCall(mod, name, substitute_list(args, replace))
        Scalar.RoutineCall(name, args) =>
            Scalar.RoutineCall(name, substitute_list(args, replace))
        Scalar.Partial(expr, var) =>
            Scalar.Partial(get(replace, expr, expr), get(replace, var, var))
        Scalar.Derivative(expr, var) =>
            Scalar.Derivative(get(replace, expr, expr), get(replace, var, var))
        Scalar.Annotate(expr, domain, unit) =>
            Scalar.Annotate(get(replace, expr, expr), domain, unit)
    end
end

function substitute_ac_set(
    terms::Dict{Scalar.Type,Num.Type}, children::Dict{Scalar.Type,Scalar.Type}
)
    new_terms = Dict{Scalar.Type,Num.Type}()
    for (key, val) in terms
        if haskey(children, key)
            new_terms[children[key]] = val
        else
            new_terms[key] = val
        end
    end
    return new_terms
end

function substitute_list(args::Vector{Scalar.Type}, replace::Dict{Scalar.Type,Scalar.Type})
    new_args = Scalar.Type[]
    sizehint!(new_args, length(args))
    for arg in args
        if haskey(replace, arg)
            push!(new_args, replace[arg])
        else
            push!(new_args, arg)
        end
    end
    return new_args
end

function Tree.is_leaf(node::Scalar.Type)
    @match node begin
        Scalar.Wildcard => true
        Scalar.Match(name) => true
        Scalar.Constant(x) => true
        Scalar.Variable(name, id) => true
        _ => false
    end
end

function Tree.print_node(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Wildcard => print(io, "_")
        Scalar.Match(name) => print(io, "\$", name)
        Scalar.Constant(x) => Tree.inline_print(io, x)
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

        Scalar.Annotate(expr, domain, unit) => print(io, "::")
    end
end

function Tree.is_infix(node::Scalar.Type)
    @match node begin
        Scalar.Pow(base, exp) => true
        Scalar.Div(num, den) => true
        _ => false
    end
end

function Tree.use_custom_print(node::Scalar.Type)
    return isa_variant(node, Scalar.Sum) ||
           isa_variant(node, Scalar.Prod) ||
           isa_variant(node, Scalar.Annotate)
end

function Tree.custom_inline_print(io::IO, node::Scalar.Type)
    @match node begin
        Scalar.Sum(coeffs, terms) => print_sum(io, coeffs, terms)
        Scalar.Prod(coeffs, terms) => print_prod(io, coeffs, terms)
        Scalar.Annotate(expr, domain, unit) => print_annotate(io, expr, domain, unit)
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

function print_sum(io::IO, coeffs::Num.Type, terms::Dict{Scalar.Type,Num.Type})
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
    return nothing
end

function print_prod(io::IO, coeffs::Num.Type, terms::Dict{Scalar.Type,Num.Type})
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
    return nothing
end
