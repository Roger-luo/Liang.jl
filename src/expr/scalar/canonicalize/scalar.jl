function remove_empty_add(node::Scalar.Type)
    isa_variant(node, Scalar.Add) || return node
    node.coeffs == Num.Zero || return node
    length(node.terms) == 1 || return node

    term, val = first(node.terms)
    if val == Num.One
        return term
    else # val * term
        return node
    end
end

"""
$SIGNATURES

Merge nested `Scalar.Add` nodes if possible.
"""
function merge_nested_add(node::Scalar.Type)
    transform = merge_nested(Scalar.Add) do coeffs, term_coeffs, val
        # val * (term.coeffs + sum[sub_val[i] * sub_terms[i]])
        # = val * term.coeffs + sum[val * sub_val[i] * sub_terms[i]]
        coeffs + val * term_coeffs
    end
    return transform(node)
end

"""
$SIGNATURES

This merge nested `Scalar.Mul` nodes if possible.
"""
function merge_nested_mul(node::Scalar.Type)
    transform = merge_nested(Scalar.Mul) do coeffs, term_coeffs, val
        # coeffs * (term.coeffs * prod[sub_terms[i]^sub_val[i]])^val
        # = coeffs*term.coeffs^val * prod[sub_terms[i]^(sub_val[i]*val)]
        coeffs * term_coeffs^val
    end
    return transform(node)
end

function merge_nested(update_coeffs, variant_type)
    function transform(node::Scalar.Type)
        isa_variant(node, variant_type) || return node
        coeffs = node.coeffs
        terms = ACSet{Scalar.Type,Num.Type}()

        for (term, val) in node.terms
            if isa_variant(term, variant_type)
                # (coeffs * prod[sub_terms^sub_val])^val
                # = coeffs^val * prod[sub_terms^(sub_val + val)]
                coeffs = update_coeffs(coeffs, term.coeffs, val)
                for (sub_term, sub_val) in term.terms
                    terms[sub_term] = sub_val * val
                end
            else
                terms[term] = val
            end
        end
        return variant_type(coeffs, terms)
    end
end

"""
$SIGNATURES

Merge `Scalar.Pow` into `Scalar.Mul`.
"""
function merge_pow_mul(node::Scalar.Type)
    isa_variant(node, Scalar.Mul) || return node
    coeffs = node.coeffs
    terms = ACSet{Scalar.Type,Num.Type}()
    for (term, val) in node.terms
        @match term begin
            Scalar.Pow(base, Scalar.Constant(exp)) => (terms[term.base] = term.exp * val)
            _ => (terms[term] = val)
        end
    end
    return Scalar.Mul(coeffs, terms)
end

"""
$SIGNATURES

Converts `Scalar.Mul` with single child to `Scalar.Pow`.
"""
function mul_to_pow(node::Scalar.Type)
    isa_variant(node, Scalar.Mul) || return node
    if Tree.n_children(node) == 1 # convert to Sum/Pow
        if node.coeffs == Num.One
            term, val = first(node.terms)
            return Scalar.Pow(term, val)
        end
    end
    return node
end

"""
$SIGNATURES

This removes `Pow` nodes with exponent `1`.
"""
function pow_one(node::Scalar.Type)
    isa_variant(node, Scalar.Pow) || return node
    if node.exp == Num.One
        return node.base
    end
    return node
end

"""
$SIGNATURES

This move coeffs of a `Scalar.Mul` into its parent
`Scalar.Add` if possible.
"""
function merge_add_mul(node::Scalar.Type)
    isa_variant(node, Scalar.Add) || return node
    coeffs = node.coeffs
    terms = ACSet{Scalar.Type,Num.Type}()
    for (term, val) in node.terms
        if isa_variant(term, Scalar.Mul)
            # + val * (coeffs * prod[sub_terms[i]^sub_val[i]])
            # = + (val * coeffs) * prod[sub_terms^sub_val]
            new_key = Scalar.Mul(1, term.terms)
            terms[new_key] = val * term.coeffs
        else
            terms[term] = val
        end
    end
    return Scalar.Add(coeffs, terms)
end

"""
$SIGNATURES

Propagate constant division into `Scalar.Add` and `Scalar.Mul`.
"""
function prop_const_div(node::Scalar.Type)
    @match node begin
        Scalar.Div(Scalar.Add(coeffs, terms), Scalar.Constant(den)) => begin
            new_coeffs = coeffs / den
            new_terms = Dict{Scalar.Type,Num.Type}()
            for (term, val) in terms
                new_terms[term] = val / den
            end
            return Scalar.Add(new_coeffs, ACSet(new_terms))
        end

        Scalar.Div(Scalar.Mul(coeffs, terms), Scalar.Constant(den)) => begin
            return Scalar.Mul(coeffs / den, terms)
        end

        _ => return node
    end
end

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
        Scalar.Wildcard => (10, 0, 0)
        Scalar.Match(_) => (11, 0, 0)
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
        _ => (18, 0, 0)
    end
end

function sort_add(node::Scalar.Type)
    isa_variant(node, Scalar.Add) || return node
    new_terms = sort(node.terms, by = term->rank(term).+rank(node.terms[term]))
    return Scalar.Add(node.coeffs, new_terms)
end

function canonicalize(node::Scalar.Type)
    p = Fixpoint(
        Chain(
            Post(merge_nested_add),
            Post(merge_nested_mul),
            Post(merge_pow_mul),
            Post(mul_to_pow),
            Post(pow_one),
            Post(merge_add_mul),
            Post(prop_const_div),
            Pre(remove_empty_add),
        ),
    )

    p = Chain(
        p,
        Post(
            Chain(
                sort_add,
            )
        )
    )
    return p(node)
end
