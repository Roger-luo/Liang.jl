@pass function emit_binding(info::EmitInfo)
    return expr_map(info.def.variants) do variant::Variant
        vinfo = info.variants[variant]::VariantInfo
        if variant.kind === Singleton
            return quote
                const $(variant.name) = $(info.type.variant)($(vinfo.tag))()
            end
        else
            quote
                const $(variant.name) = $(info.type.variant)($(vinfo.tag))
            end
        end # if
    end
end


# @pass function emit_type_getproperty(info::EmitInfo)
#     body = JLIfElse()
#     for variant::Variant in info.def.variants
#         vinfo = info.variants[variant]::VariantInfo
#         body[:(f === $(QuoteNode(variant.name)))] = quote
#             return $(info.type.variant)($(vinfo.tag))
#         end
#     end
#     body.otherwise = quote
#         return $Core.throw($Base.ArgumentError(
#             "invalid variant name: $f"
#         ))
#     end
#     reserved = (fieldnames(DataType)..., :data, :tag)

#     jl = JLFunction(;
#         name = :($Base.getproperty),
#         args = [
#             :(type::$Base.Type{$(info.type.name)}),
#             :(f::Symbol),
#         ],
#         body = quote
#             f in $(reserved) && return $Core.getfield(type, f)
#             $(codegen_ast(body))
#         end
#     )
#     codegen_ast(jl)
# end

# @pass function emit_type_propertynames(info::EmitInfo)
#     variant_names = map(info.def.variants) do variant::Variant
#         variant.name
#     end
#     names = (fieldnames(DataType)..., variant_names...)

#     jl = JLFunction(;
#         name = :($Base.propertynames),
#         args = [
#             :(type::$Base.Type{$(info.type.name)}),
#         ],
#         body = quote
#             $(names)
#         end
#     )

#     codegen_ast(jl)
# end
