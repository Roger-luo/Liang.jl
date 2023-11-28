struct CachedAnalysis{E,V}
    name::Symbol
    analysis::FunctionWrapper{V,Tuple{E}}
    cache::LRU{E,V}
    deps::Set{Symbol}
end

function CachedAnalysis{E,V}(
    analysis, deps::Vector{Symbol}=Symbol[]; maxsize::Int=100
) where {E,V}
    return CachedAnalysis(nameof(analysis), analysis, LRU{E,V}(; maxsize), Set(deps))
end

function Base.nameof(ca::CachedAnalysis)
    return ca.name
end

function (ca::CachedAnalysis{E,V})(node::E) where {E,V}
    return get!(ca.cache, node) do
        ca.analysis(node)
    end
end
