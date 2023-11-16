function inline_print(io::IO, data::Scalar.Type)
    function join(args, sep)
        for (idx, each) in enumerate(args)
            if idx > 1
                print(io, sep)
            end
            inline_print(io, each)
        end
    end

    function call(name, args)
        print(io, name, "(")
        join(args, ", ")
        print(io, ")")
    end

    @match data begin
        Scalar.Wildcard => print(io, "_")
        Scalar.Match(name) => print(io, "\$", name)
        Scalar.Constant(x) => inline_print(io, x)
        Scalar.Variable(name, id) => if id > 0 # SSA var
            print(io, "%", name)
        else
            print(io, name)
        end

        Scalar.Neg(x) => call("-", (x, ))
        Scalar.Abs(x) => call("abs", (x, ))
        Scalar.Exp(x) => call("exp", (x, ))
        Scalar.Log(x) => call("log", (x, ))
        Scalar.Sqrt(x) => call("sqrt", (x, ))

        Scalar.Sum(coeffs, terms) => print_sum(io, coeffs, terms)
        Scalar.Prod(coeffs, terms) => print_prod(io, coeffs, terms)
        Scalar.Pow(coeffs, terms) => print_pow(io, coeffs, terms)
        Scalar.Div(num, den) => print_div(io, num, den)

        Scalar.JuliaCall(mod, name, args) => call("$mod.$name", args)
        Scalar.RoutineCall(name, args) => call(name, args)

        Scalar.Annotate(expr, domain, unit) => begin
            inline_print(io, expr)
            print(io, "::")
            print(io, "<not impl>")
        end
    end
end

function print_sum(io::IO, coeffs::Num.Type, terms::Dict{Scalar.Type,Num.Type})
    @match coeffs begin
        Num.Zero => nothing
        _ => begin
            inline_print(io, coeffs)
            if !isempty(terms)
                print(io, "+")
            end
        end
    end

    io = IOContext(io, :precedence => Base.operator_precedence(:+))
    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        if !isone(coeff)
            inline_print(io, coeff)
            print(io, "*")
        end
        inline_print(io, term)
        if idx < length(terms)
            print(io, "+")
        end
    end
    return
end

function print_prod(io::IO, coeffs::Num.Type, terms::Dict{Scalar.Type,Num.Type})
    @match coeffs begin
        Num.Zero => nothing
        _ => begin
            inline_print(io, coeffs)
            if !isempty(terms)
                print(io, "*")
            end
        end
    end

    io = IOContext(io, :precedence => Base.operator_precedence(:*))
    for (idx, (term, coeff)) in enumerate(terms)
        # NOTE: we should just print all terms
        # cause otherwise they should be simplified
        # otherwise.
        # iszero(coeff) && continue
        inline_print(io, term)
        if !isone(coeff)
            print(io, "^")
            inline_print(io, coeff)
        end

        if idx < length(terms)
            print(io, "*")
        end
    end
    return
end

function print_pow(io::IO, base::Scalar.Type, exp::Scalar.Type)
    io = IOContext(io, :precedence => Base.operator_precedence(:^))
    inline_print(io, base)
    print(io, "^")
    inline_print(io, exp)
    return
end

function print_div(io::IO, num::Scalar.Type, den::Scalar.Type)
    io = IOContext(io, :precedence => Base.operator_precedence(:/))
    inline_print(io, num)
    print(io, "/")
    inline_print(io, den)
    return
end
