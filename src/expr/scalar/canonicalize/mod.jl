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
                terms[sub_term] = val * sub_val
            end
        else
            terms[term] = val
        end
    end
    return Scalar.Sum(coeffs, terms)
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
                terms[sub_term] = sub_val * val
            end
        else
            terms[term] = val
        end
    end
    return Scalar.Prod(coeffs, terms)
end

"""
$SIGNATURES

Merge `Scalar.Pow` into `Scalar.Prod`.
"""
function merge_pow_prod(node::Scalar.Type)
    isa_variant(node, Scalar.Pow) || return node
    for (term, val) in node.terms
        if isa_variant(term, Scalar.Pow)
            # (base^exp)^val
            terms[term.base] = term.exp * val
        else
            terms[term] = val
        end
    end
end

"""
$SIGNATURES

Converts `Scalar.Prod` with single child to `Scalar.Pow`.
"""
function prod_to_pow(node::Scalar.Type)
    isa_variant(node, Scalar.Prod) || return node
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
    isa_variant(node, Scalar.Sum) || return
    coeffs = node.coeffs
    terms = Dict{Scalar.Type,Num.Type}()
    for (term, val) in node.terms
        if isa_variant(term, Scalar.Prod)
            # + val * (coeffs * prod[sub_terms^sub_val])
            # = + (val * coeffs) * prod[sub_terms^sub_val]
            terms[Scalar.Prod(1, term.terms)] = val * term.coeffs
        else
            terms[term] = val
        end
    end
    return Scalar.Sum(coeffs, terms)
end
