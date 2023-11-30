function rank(val::Num.Type)
    @match val begin
        Num.Zero => (0, 0, 0)
        Num.One => (0, 1, 0)
        Num.Real(x) => (0, x, 0)
        Num.Imag(x) => (1, x, 0)
        Num.Complex(x, y) => (2, x, y)
    end
end

function rank(val::Scalar.Type)
    @match val begin
        Scalar.Constant(x) => rank(x)
        Scalar.Pi => (0, 3.14, 0)
        Scalar.Euler => (0, 2.71, 0)
        Scalar.Hbar => (12, 0, 0)
        Scalar.Variable(_) => (12, 0, 0)
        Scalar.Neg(x) => (13, 0, 0) .+ rank(x)
        Scalar.Abs(x) => (14, 0, 0) .+ rank(x)
        Scalar.Exp(x) => (15, 0, 0) .+ rank(x)
        Scalar.Log(x) => (16, 0, 0) .+ rank(x)
        Scalar.Sqrt(x) => (17, 0, 0) .+ rank(x)
        Scalar.Conj(x) => (18, 0, 0) .+ rank(x)
        _ => (19, 0, 0)
    end
end

function sort_terms(variant_type)
    return function transform(node::Scalar.Type)
        isa_variant(node, variant_type) || return node
        new_terms = sort(node.terms; by=term -> rank(term) .+ rank(node.terms[term]))
        return variant_type(node.coeffs, new_terms)
    end
end
