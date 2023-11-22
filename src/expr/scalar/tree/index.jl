function Tree.is_prefix(node::Index.Type)
    @match node begin
        Index.Neg(x) => true
        _ => false
    end
end

function Tree.is_infix(node::Index.Type)
    @match node begin
        Index.Add(lhs, rhs) => true
        Index.Sub(lhs, rhs) => true
        Index.Mul(lhs, rhs) => true
        Index.Div(lhs, rhs) => true
        Index.Rem(lhs, rhs) => true
        Index.Pow(lhs, rhs) => true
        _ => false
    end
end

function Tree.precedence(node::Index.Type)
    @match node begin
        Index.Constant(x) => x < 0 ? 0 : 100
        Index.Variable(_) => 100
        Index.NSites(_) => 100
        Index.Wildcard => 100
        Index.Match(_) => 100
        Index.Add(lhs, rhs) => 1
        Index.Sub(lhs, rhs) => 1
        Index.Mul(lhs, rhs) => 2
        Index.Div(lhs, rhs) => 2
        Index.Rem(lhs, rhs) => 2
        Index.Pow(lhs, rhs) => 3
        _ => 0
    end
end

function Tree.print_node(io::IO, node::Index.Type)
    @match node begin
        Index.Wildcard => print(io, "_")
        Index.Constant(x) => print(io, x)
        Index.Variable(; name, id) => Tree.print_variable(io, name, id)
        Index.Add(lhs, rhs) => print(io, "+")
        Index.Sub(lhs, rhs) => print(io, "-")
        Index.Mul(lhs, rhs) => print(io, "*")
        Index.Div(lhs, rhs) => print(io, "/")
        Index.Rem(lhs, rhs) => print(io, "%")
        Index.Pow(lhs, rhs) => print(io, "^")
        Index.Max(lhs, rhs) => print(io, "max")
        Index.Min(lhs, rhs) => print(io, "min")
        Index.Neg(x) => print(io, "-")
        Index.Abs(x) => print(io, "abs")
        Index.NSites(name) => print(io, "n_sites(@$name)")
        Index.AssertEqual(_) => print(io, "assert_equal")
    end
end

function Tree.print_meta(io::IO, node::Index.Type)
    @match node begin
        Index.AssertEqual(lhs, rhs, msg) => if isempty(msg)
            return nothing
        else
            printstyled(io, '"', msg, '"'; color=:yellow)
        end
        _ => nothing
    end
end
