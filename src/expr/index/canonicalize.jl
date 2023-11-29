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

struct MergeNested{E,V}
    update_coeffs::FunctionWrapper{V,Tuple{V,V,V}}
    variant_type::Type{E}
end

function merge_nested(f_update_coeffs, ::Type{E}, variant_type) where {E}
    function transform(node::E)
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
