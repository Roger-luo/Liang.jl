


function check_inputs(ops, coeffs)
    length(ops) == 0 && throw(ArgumentError("ops must not be empty"))

    if length(ops) != length(coeffs)
        throw(DimensionMismatch("ops and coeffs must have the same length"))
    end

    eltype(coeffs) <: Union{Number, Function} || 
        throw(ArgumentError("coeffs must be a vector of numbers or functions"))

    eltype(ops) <: AbstractMatrix || 
        throw(ArgumentError("ops must be a vector of arrays"))

    size = size(first(ops))
    size[]

    for op in ops
        eltype(op) <: Number || 
            throw(ArgumentError("ops must be a vector of arrays of numbers"))
        size(op) == size ||
            throw(DimensionMismatch("all ops must have the same size"))
    end
end

function check_function(f)
    f
end


struct Hamiltonian{Ops, Coeffs} <: AbstractMatrix
    ops::Ops
    coeffs::Coeffs

    function Hamiltonian(ops::AbstractVector, coeffs::AbstractVector)
        check_inputs(ops, coeffs)

        coeffs = map(coeffs) do coeff
            if coeff isa Function
                check_function(coeff)
            else
                t -> coeff
            end
        end

        ops_tuple = tuple(ops...)
        coeffs_tuple = tuple(coeffs...)

        new{typeof(ops), typeof(coeffs)}(ops_tuple, coeffs_tuple)
    end

end

Base.length(h::Hamiltonian) = length(h.ops)
Base.size(h::Hamiltonian) = size(first(h.ops))

function (h::Hamiltonian)(time::Real, input::AbstractVector, output::AbstractVector)
    @debug begin
        length(input) == length(output) || 
            throw(DimensionMismatch("input and output must have the same length"))
        length(input) == size(h, 2) || 
            throw(DimensionMismatch("input length must match Hamiltonian size"))        
    end

    output .= zero(eltype(output))
    for (op, coeff) in zip(h.ops, h.coeffs)
        output .+= coeff(time) * op * input
    end
end
    