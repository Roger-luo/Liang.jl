

struct PythonModuleInfo
    package_name::String
    data_types::Vector{Module}
end


@data PythonCodeGenError begin
    struct PythonTypeError
        message::String
    end
end


function emit_data_type_module(data_type)
    name = data_type_name(data_type)

    base_type = join([
        "@dataclass(frozen=True)",
        "class $(name)Expr:",
        "    pass"
    ], "\n")

    variant_definitions = map(variants(data_type)) do variant_type
        emit_python_variant(data_type_name(data_type), variant_type)
    end

    class_definitinos = [
        base_type,
        variant_definitions...
    ]

   join(class_definitinos, "\n\n")
end



function emit_python_variant(adt_name, variant_type)
    name = variant_name(variant_type)

    is_singleton(variant_type) && "@dataclass(frozen=True)\nclass $name($(adt_name)Expr):\n    pass"
    
    field_names = variant_fieldnames(variant_type)
    field_types = variant_fieldtypes(variant_type)
    variant_field_definitions = map(field_names, field_types) do field_name, field_type
        python_type = emit_python_type(field_type)
        if python_type isa PythonCodeGenError.Type
            error(python_type.message)
        end
        if field_name isa Number
            field_name = "field_$field_name"
        end
            
        "    $field_name: $(python_type)"
    end

    lines = [
        "@dataclass(frozen=True)",
        "class $name($(variant_name)Expr):",
        variant_field_definitions...
    ]
    
    join(lines, "\n")

end




function flatten_union_types(union_type)
    if typeof(union_type) != Union
        return [union_type]
    end
    [union_type.a, flatten_union_types(union_type.b)...]
end

function emit_python_type(jl_type)::Union{String, PythonCodeGenError.Type}
    @match jl_type begin
        $Bool => "bool"
        $Nothing => "None"
        $Symbol => "str"
        if jl_type <: AbstractString end => "str"
        if jl_type <: AbstractFloat end => "Decimal"
        if jl_type <: Integer end => "int"
        if jl_type <: Complex end => "complex"
        if is_data_type(jl_type) end => data_type_name(jl_type)
        if jl_type <: AbstractVector end => "List[$(emit_python_type(eltype(jl_type)))]"
        if jl_type <: AbstractSet end => "FrozenSet[$(emit_python_type(eltype(jl_type)))]"
        if jl_type <: Tuple end => begin
            sub_types_str = join(map(emit_python_type, fieldtypes(jl_type)), ", ")
            "Tuple[$sub_types_str]"
        end
        if jl_type <: AbstractDict end => begin
            key_type, value_type = fieldtypes(eltype(jl_type))
            "Dict[$(emit_python_type(key_type)), $(emit_python_type(value_type))]"
        end
        if typeof(jl_type) == Union end => begin
            sub_types = flatten_union_types(jl_type)
            sub_types_str = join(map(emit_python_type, sub_types), ", ")
            "Union[$sub_types_str]"
        end
        _ => PythonCodeGenError.PythonTypeError("Unsupported type: $jl_type")
    end
end
