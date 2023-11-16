using Liang.Expression: Scalar, Num, Index, @scalar_str, @index_str
using Liang.Match: @match
using Liang.Tree

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
        Index.Add(lhs, rhs) => 1
        Index.Sub(lhs, rhs) => 1
        Index.Mul(lhs, rhs) => 2
        Index.Div(lhs, rhs) => 2
        Index.Rem(lhs, rhs) => 2
        Index.Pow(lhs, rhs) => 3
        _ => 0
    end
end

function Tree.substitute(node::Index.Type, children::Tuple)
    @match node begin
        Index.Add(lhs, rhs) => Index.Add(children...)
        Index.Sub(lhs, rhs) => Index.Sub(children...)
        Index.Mul(lhs, rhs) => Index.Mul(children...)
        Index.Div(lhs, rhs) => Index.Div(children...)
        Index.Rem(lhs, rhs) => Index.Rem(children...)
        Index.Pow(lhs, rhs) => Index.Pow(children...)
        Index.Neg(x) => Index.Neg(children[1])
        Index.Abs(x) => Index.Abs(children[1])
        _ => node
    end
end

function Tree.children(node::Index.Type)
    @match node begin
        Index.Add(lhs, rhs) => [lhs, rhs]
        Index.Sub(lhs, rhs) => [lhs, rhs]
        Index.Mul(lhs, rhs) => [lhs, rhs]
        Index.Div(lhs, rhs) => [lhs, rhs]
        Index.Rem(lhs, rhs) => [lhs, rhs]
        Index.Pow(lhs, rhs) => [lhs, rhs]
        Index.Neg(x) => [x]
        Index.Abs(x) => [x]
        _ => Index.Type[]
    end
end

function Tree.print_node(io::IO, node::Index.Type)
    @match node begin
        Index.Wildcard => print(io, "_")
        Index.Constant(x) => print(io, x)
        Index.Variable(;name) => print(io, name)
        Index.Add(lhs, rhs) => print(io, "+")
        Index.Sub(lhs, rhs) => print(io, "-")
        Index.Mul(lhs, rhs) => print(io, "*")
        Index.Div(lhs, rhs) => print(io, "/")
        Index.Rem(lhs, rhs) => print(io, "%")
        Index.Pow(lhs, rhs) => print(io, "^")
        Index.Neg(x) => print(io, "-")
        Index.Abs(x) => print(io, "abs")
    end
end

ex1 = (index"i" + 2) * index"j"
ex2 = index"i" + 2 * index"j"^3

Tree.inline_print(stdout, ex2)
