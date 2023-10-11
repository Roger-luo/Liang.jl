@data Pattern begin
    Wildcard
    Variable(Symbol)
    Constant(Any)

    And(Pattern, Pattern)
    Or(Pattern, Pattern)

    struct Call
        head::Pattern
        args::Vector{Pattern}
        kwargs::Dict{Symbol, Pattern}
    end

    struct Dot
        head::Pattern
        name::Pattern
    end

    struct Tuple
        xs::Vector{Pattern}
    end

    struct NamedTuple
        names::Vector{Symbol}
        xs::Vector{Pattern}
    end

    struct Vector
        xs::Vector{Pattern}
    end

    struct VCat
        xs::Vector{Pattern}
    end

    struct NCat
        n::Int
        xs::Vector{Pattern}
    end

    # <splat>...
    struct Splat
        body::Pattern
    end

    struct Comprehension
        body::Pattern
        vars::Vector{Symbol}
        iterators::Vector{Pattern}
        guard::Pattern
    end
end
