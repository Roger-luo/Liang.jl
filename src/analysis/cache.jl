struct CachedAnalysis{E,V}
    name::Symbol
    analysis::FunctionWrapper{V,Tuple{E}}
    cache::Dict{E,V}
    deps::Set{Symbol}
end

function CachedAnalysis{E,V}(analysis, deps::Vector{Symbol}=[])
    return CachedAnalysis(nameof(analysis), analysis, Dict{E,V}(), Set(deps))
end

function Base.nameof(ca::CachedAnalysis)
    return ca.name
end

function (ca::CachedAnalysis{E,V})(node::E) where {E}
    haskey(ca.cache, node) && return ca.cache[node]
    result = ca.analysis(node)
    ca.cache[node] = result
    return result::V
end
