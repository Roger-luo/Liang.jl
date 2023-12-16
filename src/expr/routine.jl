struct Routine{E}
    name::Symbol
    # Variable.Slot
    args::Vector{Symbol}
    # scan expression types
    # of the corresponding variable
    # at construction, so we can validate
    # the input without walk through the
    # expression.
    types::Vector{Any}
    body::E
end
