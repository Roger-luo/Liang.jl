@data Device begin
    CPU
    GPU(Int)
end

"""
The tensor language for describing general tensor networks.
"""
@data Tensor begin
    # TODO: figure out what the tensor interface should be
    # maybe add some checks in constructor?
    # any data satisfying the tensor interface
    # - reshape
    # - permute
    # - transpose
    # - adjoint
    # - mul!
    Constant(Any)

    struct Variable
        name::Symbol
        dims::Vector{Index}
    end

    struct Device
        device::Device.Type
        tensor::Tensor
    end

    struct Reshape
        tensor::Tensor
        dims::Vector{Index}
    end

    # bundle a few legs into one
    struct Bundle
        tensor::Tensor
        # new => old continuous legs
        legs::Vector{UnitRange{Int}}
        # bi-directional map
        # old => new leg id
        old_legs::Vector{Int}
    end

    struct Slice
        tensor::Tensor
        # old => new leg dims
        dims::Vector{Vector{Index}}
        # new => old id
        legs::Vector{Int}
    end

    struct PermuteDims
        tensor::Tensor
        perm::Vector{Index}
    end

    struct Conjugate
        tensor::Tensor
    end

    struct Contract
        tensor1::Tensor
        tensor2::Tensor
        indices1::Vector{Int}
        indices2::Vector{Int}
    end

    struct Trace
        tensor::Tensor
        indices1::Vector{Int}
        indices2::Vector{Int}
    end
end