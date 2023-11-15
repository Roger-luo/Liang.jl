include("num.jl")
include("index.jl")
include("scalar.jl")

for type in [Num.Type, Index.Type, Scalar.Type]
    @eval function Data.show_data(io::IO, x::$type)
        return inline_print(io, x)
    end
end
