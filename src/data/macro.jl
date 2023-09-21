# @data MyADT begin
#     Foo
#     Bar(Int, Float64)

#     struct Baz
#         x::Int
#         y::Float64
#         z::Vector{MyADT}
#     end
# end

macro data(name::Symbol, expr)
    return esc(data_m(name, expr))
end

function data_m(name::Symbol, expr)
    expr isa Expr || throw(SyntaxError("Expected an \
        expression, got $(typeof(expr)): $expr"))
end
