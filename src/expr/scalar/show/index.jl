function inline_print(io::IO, x::Index.Type)
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

    @match x begin
        Index.Wildcard => print(io, "_")
        Index.Match(name) => print(io, "\$", name)
        Index.Constant(x) => inline_print(io, x)
        Index.Variable(name, id) => if id > 0 # SSA var
            print(io, "%", name)
        else
            print(io, name)
        end

        Index.Add(lhs, rhs) => inline_print_binop(io, :+, lhs, rhs)
        Index.Sub(lhs, rhs) => inline_print_binop(io, :-, lhs, rhs)
        Index.Mul(lhs, rhs) => inline_print_binop(io, :*, lhs, rhs)
        Index.Div(lhs, rhs) => inline_print_binop(io, :/, lhs, rhs)
        Index.Rem(lhs, rhs) => inline_print_binop(io, :%, lhs, rhs)
        Index.Pow(lhs, rhs) => inline_print_binop(io, :^, lhs, rhs)
        Index.Neg(x) => call("-", (x, ))
        Index.Abs(x) => call("abs", (x, ))
    end    
end

function inline_print_binop(io, op::Symbol, lhs, rhs)
    pred = Base.operator_precedence(op)
    inline_print(io, lhs)
    print(io, op)
    inline_print(io, rhs)
end
