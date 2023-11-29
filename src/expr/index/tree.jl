function Tree.Print.print_node(io::IO, node::Index.Type)
    @match node begin
        Index.Inf => print(io, "∞")
        Index.Constant(x) || Index.Variable(x) || Index.NSites(x) => print(io, x)
        Index.Abs(x) => print(io, "abs")
        Index.Add(_) => print(io, "+")
        Index.Mul(_) => print(io, "*")
        Index.Div(_) => print(io, "÷")
        Index.Pow(_) => print(io, "^")
        Index.Rem(_) => print(io, "%")
        Index.Max(_) => print(io, "max")
        Index.Min(_) => print(io, "min")
        Index.AssertEqual(_, _) => print(io, "==")
    end
end

function Tree.Print.is_infix(node::Index.Type)
    @match node begin
        Index.Pow(_) => true
        Index.Div(_) => true
        Index.Rem(_) => true
        _ => false
    end
end

function Tree.Print.use_custom_print(node::Index.Type)
    @match variant_type(node) begin
        Index.Add => true
        Index.Mul => true
        Index.Max => true
        Index.Min => true
        Index.AssertEqual => true
        _ => false
    end
end

function Tree.Print.custom_inline_print(io::IO, node::Index.Type)
    @match node begin
        Index.Add(coeffs, terms) => begin
            if !iszero(coeffs)
                print(io, coeffs)
                if !isempty(terms)
                    print(io, "+")
                end
            end
            Tree.Print.print_add(io, terms)
        end
        Index.Mul(coeffs, terms) => begin
            if !isone(coeffs)
                print(io, coeffs)
                if !isempty(terms)
                    print(io, "*")
                end
            end
            Tree.Print.print_mul(io, terms)
        end
        Index.Max(terms) => begin
            print(io, "max")
            print(io, "(")
            Tree.Print.inline_list(io, terms)
            print(io, ")")
        end
        Index.Min(terms) => begin
            print(io, "min")
            print(io, "(")
            Tree.Print.inline_list(io, terms)
            print(io, ")")
        end
    end
end

function Tree.Print.precedence(node::Index.Type)::Int
    @match node begin
        if Tree.is_leaf(node)
        end => 100
        Index.Add(_) => Base.operator_precedence(:+)
        Index.Mul(_) => Base.operator_precedence(:*)
        Index.Pow(_) => Base.operator_precedence(:^)
        Index.Div(_) => Base.operator_precedence(:/)
        Index.Rem(_) => Base.operator_precedence(:%)
        _ => 0
    end
end

function Tree.Print.print_meta(io::IO, node::Index.Type)
    @match node begin
        Index.Add(coeffs) => if !iszero(coeffs)
            print(io, coeffs)
        end
        Index.Mul(coeffs) => if !isone(coeffs)
            print(io, coeffs)
        end
        _ => nothing
    end
end
