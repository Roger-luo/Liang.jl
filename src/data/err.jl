Base.@kwdef struct SyntaxError <: Exception
    msg::String
end

function Base.showerror(io::IO, e::SyntaxError)
    print(io, e.msg)
end
