module Hash

mutable struct HashCache
    value::UInt64

    HashCache() = new()
    HashCache(value::UInt64) = new(value)
end

Base.getindex(cache::HashCache) = cache.value
Base.setindex!(cache::HashCache, value) = cache.value = value

end
