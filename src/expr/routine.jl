struct Routine{E}
    name::Symbol
    # Variable.Slot
    args::Vector{Symbol}
    body::E
end
