@pass 3 function emit_storage_cons(info::EmitInfo)
    @gensym tag bits ptrs
    quote
        function $(info.type.storage.name)(tag::UInt8, bits::Tuple, ptrs::Tuple)
            $tag = $(xtuple(:tag, (zero(UInt8) for _ in 1:(info.type.storage.size.tag-1))...))
            $bits = $Data.unsafe_padded_reinterpret(NTuple{$(info.type.storage.size.bits), UInt8}, bits)
            $ptrs = $Data.padded_tuple_any(Val($(info.type.storage.size.ptrs)), ptrs)
            return $(info.type.storage.name)($tag, $bits, $ptrs)
        end
    end
end

@pass 4 function emit_cons(info::EmitInfo)
    quote
        function (type::$(info.type.variant))(args...; kwargs...)
            $(emit_cons_body(info))
        end
    end
end

function emit_cons_body(info::EmitInfo)
    foreach_variant(info, :(type.tag)) do variant::Variant, vinfo::VariantInfo
        emit_variant_cons(info, variant, vinfo)
    end
end

function emit_variant_cons(info::EmitInfo, variant::Variant, vinfo::VariantInfo)
    if (variant.kind === Singleton || variant.kind === Anonymous)
        return emit_positional_cons(info, variant, vinfo)
    end
    # variant.kind === Named
    quote
        if !isempty(args) && !isempty(kwargs)
            throw(ArgumentError("cannot mix positional and keyword arguments"))
        elseif isempty(args)
            $(emit_kwargs_cons(info, variant, vinfo))
        else
            $(emit_positional_cons(info, variant, vinfo))
        end
    end
end

function emit_kwargs_cons(info::EmitInfo, variant::Variant, vinfo::VariantInfo)
    bits, ptrs = Expr(:tuple), Expr(:tuple)
    body = expr_map(enumerate(vinfo)) do (kth_field, finfo)
        @gensym kw val
        field = variant.fields[kth_field]::NamedField
        get_kw =  if field.default === no_default
            quote
                haskey(kwargs, $(QuoteNode(field.name))) ||
                    throw(ArgumentError("missing keyword argument $($(field.name))"))
                kwargs[$(QuoteNode(field.name))]
            end
        else
            quote
                get(kwargs, $(QuoteNode(field.name)), $(field.default))
            end
        end

        if finfo.is_bitstype
            push!(bits.args, val)
        else
            push!(ptrs.args, val)
        end

        # TODO: correct this, use original type
        quote
            $kw = $get_kw
            $val = $Base.convert($(finfo.type), $kw)
        end
    end

    return quote
        $body
        $(info.type.name)($(info.type.storage.name)(type.tag, $bits, $ptrs))
    end
end

function emit_positional_cons(info::EmitInfo, variant::Variant, vinfo::VariantInfo)
    bits_expr, ptrs_expr = Expr(:tuple), Expr(:tuple)
    for (kth_field, finfo::FieldInfo) in enumerate(vinfo)
        finfo.is_bitstype &&
        push!(bits_expr.args, :(
            $Base.convert($(finfo.type), args[$kth_field])
        ))

        !finfo.is_bitstype &&
        push!(ptrs_expr.args, :(
            $Base.convert($(finfo.type), args[$kth_field])
        ))
    end

    @gensym bits ptrs
    return quote
        length(args) == $(length(vinfo)) || throw(ArgumentError(
            "wrong number of arguments, expect $($(length(vinfo)))")
        )
        $bits = $bits_expr
        $ptrs = $ptrs_expr
        $(info.type.name)($(info.type.storage.name)(type.tag, $bits, $ptrs))
    end
end
