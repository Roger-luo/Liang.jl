Base.@kwdef struct SyntaxError <: Exception
    msg::String
    source::Union{Nothing,LineNumberNode} = nothing
end

function Base.showerror(io::IO, e::SyntaxError)
    print(io, e.msg)
end

Base.@kwdef struct InvalidMethodError <: Exception end

function Base.showerror(io::IO, e::InvalidMethodError)
    print(io, "Invalid method, expect to be generated by Moshi.Data.@data")
end

invalid_method() = throw(InvalidMethodError())
