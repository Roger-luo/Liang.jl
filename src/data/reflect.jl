is_datatype(variant_instance_or_type)::Bool = false
data_type_name(variant_instance_or_type)::Symbol = invalid_method()
data_type_module(variant_instance_or_type)::Module = invalid_method()
variant_name(variant_instance_or_type)::Symbol = invalid_method()
variant_kind(variant_instance_or_type)::VariantKind = invalid_method()
variant_type(variant_instance) = invalid_method()
variant_storage(variant_instance) = invalid_method()
variant_tag(variant_instance)::UInt8 = invalid_method()
variant_fieldnames(variant_instance)::Tuple = invalid_method()
variant_fieldtypes(variant_instance, idx::Int)::Tuple = invalid_method()
variant_nfields(variant_instance)::Int = invalid_method()
is_singleton(variant_instance_or_type)::Bool = invalid_method()
variant_fieldname(variant_instance, idx::Int)::Symbol = variant_fieldnames(variant_instance)[idx]
variant_fieldtype(variant_instance, idx::Int)::Symbol = variant_fieldtypes(variant_instance)[idx]

function isa_variant(instance, variant)
    is_singleton(instance) && return instance === variant
    return variant_type(instance) === variant
end
