@pass function emit_data_type_name(info::EmitInfo)
    return quote
        function $Data.data_type_name(::$Base.Type{$(info.type.name)})
            return $(QuoteNode(info.def.name))
        end

        function $Data.data_type_name(::$Base.Type{$(info.type.variant)})
            return $(QuoteNode(info.def.name))
        end

        function $Data.data_type_name(::$(info.type.name))
            return $(QuoteNode(info.def.name))
        end

        function $Data.data_type_name(::$(info.type.variant))
            return $(QuoteNode(info.def.name))
        end
    end
end

function emit_variant_name(info::EmitInfo)
    body = foreach_variant(info, :tag) do variant::Variant, vinfo::VariantInfo
        return QuoteNode(variant.name)
    end

    return quote
        function $Data.variant_name(type::$(info.type.name))
            $(emit_get_data_tag(info))
            $body
        end
    end
end

@pass function emit_is_singleton_on_instance(info::EmitInfo)
    body = foreach_variant(info, :tag) do variant::Variant, vinfo
        variant.kind == Singleton && return true
        return false
    end
    return quote
        function $Data.is_singleton(type::$(info.type.name))
            $(emit_get_data_tag(info))
            $body
        end
    end
end

@pass function emit_is_singleton_on_variant_type(info::EmitInfo)
    body = foreach_variant(info, :tag) do variant::Variant, vinfo
        variant.kind == Singleton && return true
        return false
    end
    return quote
        function $Data.is_singleton(variant_type::$(info.type.variant))
            tag = variant_type.tag
            $body
        end
    end
end
