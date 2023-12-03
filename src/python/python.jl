


struct PythonModuleInfo
    name::String
end





function python_type(jl_type)::String
    function flatten_union_types(union_type::Union)
        [union_type.a, flatten_union_types(union_type.b)...]
    end

    println(jl_type)

    result = @match jl_type begin
        Float => "float"
        Int => "int"
        Complex => "complex"
        Bool => "bool"
        Symbol => "str"
        String => "str"
        Nothing => "None"
        Vector => "List[$(python_type(eltype(type)))]"
        Set => "FrozenSet[$(python_type(eltype(type)))]"
        Tuple => begin
            sub_types_str = join(map(python_type, fieldtypes(type)), ", ")
            "Tuple[$sub_types_str]"
        end
        Dict => begin
            key_type, value_type = fieldtypes(eltype(type))
            "Dict[$(python_type(key_type)), $(python_type(value_type))]"
        end
        Union => begin
            sub_types = flatten_union_types(type)
            sub_types_str = join(map(python_type, sub_types), ", ")
            "Union[$sub_types_str]"
        end
        _ => "Any"
    end
    println(result)
    return result
end

