"""
$SIGNATURES

Merge nested `Scalar.Sum` nodes if possible.
"""
function merge_nested_sum(node::Scalar.Type)
    isa_variant(node, Scalar.Sum) || return node
    coeffs = node.coeffs
    terms = Dict{Scalar.Type,Num.Type}()

    for (term, val) in node.terms
        if isa_variant(term, Scalar.Sum)
            # val * (coeffs + sum[sub_val * sub_terms])
            # = val * coeffs + sum[(val * sub_val) * sub_terms]
            coeffs += val * term.coeffs
            for (sub_term, sub_val) in term.terms
                update_ac_set!(terms, sub_term, val * sub_val)
            end
        else
            update_ac_set!(terms, term, val)
        end
    end
    return Scalar.Sum(coeffs, terms)
end

function remove_empty_sum(node::Scalar.Type)
    isa_variant(node, Scalar.Sum) || return node
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

This merge nested `Scalar.Prod` nodes if possible.
"""
function merge_nested_prod(node::Scalar.Type)
    isa_variant(node, Scalar.Prod) || return node
    coeffs = node.coeffs
    terms = Dict{Scalar.Type,Num.Type}()

    for (term, val) in node.terms
        if isa_variant(term, Scalar.Prod)
            # (coeffs * prod[sub_terms^sub_val])^val
            # = coeffs^val * prod[sub_terms^(sub_val + val)]
            coeffs *= term.coeffs^val
            for (sub_term, sub_val) in term.terms
                update_ac_set!(terms, sub_term, sub_val * val)
            end
        else
            update_ac_set!(terms, term, val)
        end
    end
    return Scalar.Prod(coeffs, terms)
end

"""
$SIGNATURES

Merge `Scalar.Pow` into `Scalar.Prod`.
"""
function merge_pow_prod(node::Scalar.Type)
    isa_variant(node, Scalar.Prod) || return node
    coeffs = node.coeffs
    terms = Dict{Scalar.Type,Num.Type}()
    for (term, val) in node.terms
        @match term begin
            Scalar.Pow(base, Scalar.Constant(exp)) =>
                update_ac_set!(terms, term.base, term.exp * val)
            _ => update_ac_set!(terms, term, val)
        end
    end
    return Scalar.Prod(coeffs, terms)
end

"""
$SIGNATURES

Converts `Scalar.Prod` with single child to `Scalar.Pow`.
"""
function prod_to_pow(node::Scalar.Type)
    isa_variant(node, Scalar.Prod) || return node
    coeffs = node.coeffs
    terms = Dict{Scalar.Type,Num.Type}()
    if Tree.n_children(node) == 1 # convert to Sum/Pow
        term, val = first(node.terms)
        if coeffs == Num.One
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

This move coeffs of a `Scalar.Prod` into its parent
`Scalar.Sum` if possible.
"""
function merge_sum_prod(node::Scalar.Type)
    isa_variant(node, Scalar.Sum) || return node
    coeffs = node.coeffs
    terms = Dict{Scalar.Type,Num.Type}()
    for (term, val) in node.terms
        if isa_variant(term, Scalar.Prod)
            # + val * (coeffs * prod[sub_terms^sub_val])
            # = + (val * coeffs) * prod[sub_terms^sub_val]
            new_key = Scalar.Prod(1, term.terms)
            update_ac_set!(terms, new_key, val * term.coeffs)
        else
            update_ac_set!(terms, term, val)
        end
    end
    return Scalar.Sum(coeffs, terms)
end

"""
$SIGNATURES

Propagate constant division into `Scalar.Sum` and `Scalar.Prod`.
"""
function prop_const_div(node::Scalar.Type)
    @match node begin
        Scalar.Div(Scalar.Sum(coeffs, terms), Scalar.Constant(den)) => begin
            new_coeffs = coeffs / den
            new_terms = Dict{Scalar.Type,Num.Type}()
            for (term, val) in terms
                new_terms[term] = val / den
            end
            return Scalar.Sum(new_coeffs, new_terms)
        end

        Scalar.Div(Scalar.Prod(coeffs, terms), Scalar.Constant(den)) => begin
            return Scalar.Prod(coeffs / den, terms)
        end

        _ => return node
    end
end

function update_ac_set!(terms::Dict, term, val)
    if haskey(terms, term)
        terms[term] = terms[term] + val
    else
        terms[term] = val
    end
    return terms
end

function canonicalize(node::Scalar.Type)
    p = Pre(
        Fixpoint(
            Chain(
                merge_nested_sum,
                merge_nested_prod,
                merge_pow_prod,
                prod_to_pow,
                pow_one,
                merge_sum_prod,
                prop_const_div,
                remove_empty_sum,
            ),
        ),
    )
    return p(node)
end
