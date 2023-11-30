function parse_var(f, s::AbstractString)
    if (m = match(r"%([0-9]+)", s); !isnothing(m))
        id = parse(Int64, m.captures[1])
        id > 0 || error("invalid SSA id: $id ≤ 0")
        return f(Variable.SSA(id))
    elseif m == "_"
        return f(Variable.Wildcard)
    elseif startswith(s, "\$")
        return f(Variable.Match(Symbol(s[2:end])))
    else
        return f(Variable.Slot(Symbol(s)))
    end
end

function remove_empty_add(node_type)
    function transform(node)
        isa_variant(node, node_type) || return node
        iszero(node.coeffs) || return node
        length(node.terms) == 1 || return node

        term, val = first(node.terms)
        if isone(val)
            return term
        else # val * term
            return node
        end
    end # transform
end

struct MergeNested{E,V,VT}
    accum_coeffs::FunctionWrapper{V,Tuple{V,V,V}}
    variant_type::VT
end

function MergeNested{E,V}(f, variant_type::VT) where {E,V,VT}
    return MergeNested{E,V,VT}(f, variant_type)
end

function accum_coeffs_add(coeffs, sub_coeffs, val)
    # val * (term.coeffs + sum[sub_val[i] * sub_terms[i]])
    # = val * term.coeffs + sum[val * sub_val[i] * sub_terms[i]]
    return coeffs + sub_coeffs * val
end

function accum_coeffs_mul(coeffs, sub_coeffs, val)
    # val * (term.coeffs * prod[sub_val[i] * sub_terms[i]])
    # = val * term.coeffs * prod[sub_val[i] * sub_terms[i]]
    return coeffs * sub_coeffs^val
end

function (mn::MergeNested{E,V})(node::E) where {E,V}
    isa_variant(node, mn.variant_type) || return node
    coeffs = node.coeffs
    terms = ACSet{E,V}()
    for (term, val) in node.terms
        if isa_variant(term, mn.variant_type)
            # (coeffs * prod[sub_terms^sub_val])^val
            # = coeffs^val * prod[sub_terms^(sub_val + val)]
            coeffs = mn.accum_coeffs(coeffs, term.coeffs, val)
            for (sub_term, sub_val) in term.terms
                terms[sub_term] = sub_val * val
            end
        else
            terms[term] = val
        end
    end
    return mn.variant_type(coeffs, terms)
end

struct MergePowMul{E,V,VT}
    mul::VT
    pow::VT
    constant::VT
end

function (mp::MergePowMul{E,V})(node::E) where {E,V}
    isa_variant(node, mp.mul) || return node
    coeffs = node.coeffs
    terms = ACSet{E,V}()
    for (term, val) in node.terms
        if isa_variant(term, mp.pow) && isa_variant(term.exp, mp.constant)
            base = term.base
            exp = term.exp.:1
            terms[base] = exp * val
        else
            terms[term] = val
        end
    end
    return mp.mul(coeffs, terms)
end
