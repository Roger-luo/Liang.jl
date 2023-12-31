using ExproniconLite
using Liang.Data: @data
using Liang.Data: Data, Emit, TypeDef, EmitInfo

@data Pattern begin
    Wildcard

    struct Tuple
        xs::Vector{Pattern}
    end
end

xs = Pattern.Tuple([Pattern.Wildcard])

def = TypeDef(
    Main,
    :Pattern,
    quote
        Wildcard

        struct Tuple
            xs::Vector{Pattern}
        end
    end,
)

info = EmitInfo(def)
Emit.emit_variant_getfield_num(info)
ex = Emit.emit_cons(info)
