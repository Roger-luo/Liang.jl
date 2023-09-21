struct SizeInfo
    tag::Int
    bits::Int
    ptrs::Int
end

struct FieldInfo
    var::Symbol
    expr::Union{Symbol,Expr}
    is_bitstype::Bool
    type_guess # eval-ed type
end

struct VariantInfo
    def::Variant
    tag::UInt8
    fields::Vector{FieldInfo}
end

struct EmitInfo
    def::TypeDef
    size::SizeInfo
    variants::Dict{Variant, VariantInfo}
end
