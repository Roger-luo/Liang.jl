struct Context{E}
    analysis::Dict{Symbol,CachedAnalysis{E}}
end # Context

function Context{E}(analysis::CachedAnalysis{E}...) where {E}
    registry = Dict{Symbol,CachedAnalysis{E}}()
    for each in analysis
        registry[nameof(each)] = each
    end
    return Context{E}(registry)
end

function Base.getproperty(ctx::Context, name::Symbol)
    return getfield(ctx, :analysis)[name]
end

function Base.setproperty!(
    ctx::Context{E}, name::Symbol, analysis::CachedAnalysis{E}
) where {E}
    getfield(ctx, :analysis)[name] = analysis
    return ctx
end

function invalidate!(ctx::Context, name::Symbol, node::E) where {E}
    analysis = ctx[name]
    delete!(analysis.cache, node)
    for dep in analysis.deps
        invalidate!(ctx, dep, node)
    end
    return ctx
end
