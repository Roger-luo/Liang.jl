struct Routine{E}
    name::Symbol
    # Variable of the same type E
    args::Vector{Symbol}
    body::E
end

struct RoutineTable{E}
    routines::Dict{Symbol,Routine{E}}
end

RoutineTable{E}() where {E} = RoutineTable{E}(Dict{Symbol,Routine{E}}())

struct RoutineRegistry
    op::RoutineTable{Op.Type}
    state::RoutineTable{State.Type}
    scalar::RoutineTable{Scalar.Type}
    index::RoutineTable{Index.Type}
    tensor::RoutineTable{Tensor.Type}
end

function RoutineRegistry()
    return RoutineRegistry(
        RoutineTable{Op.Type}(),
        RoutineTable{State.Type}(),
        RoutineTable{Scalar.Type}(),
        RoutineTable{Index.Type}(),
        RoutineTable{Tensor.Type}(),
    )
end

function Base.setindex!(table::RoutineTable{E}, routine::Routine{E}) where {E}
    table.routines[routine.name] = routine
    return table
end

function Base.setindex!(registry::RoutineRegistry, routine::Routine{E}) where {E}
    if E isa Op.Type
        registry.op[] = routine
    elseif E isa State.Type
        registry.state[] = routine
    elseif E isa Scalar.Type
        registry.scalar[] = routine
    elseif E isa Index.Type
        registry.index[] = routine
    elseif E isa Tensor.Type
        registry.tensor[] = routine
    else
        error("expect Op, State, Scalar, Index or Tensor, got: $E")
    end
    return registry
end

# TODO: think about how we interact with Julia modules
const ROUTINE_REGISTRY = RoutineRegistry()
