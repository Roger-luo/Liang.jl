"""
$TYPEDEF

An storage type represents a set of terms that are
associative and commutative. This type is exactly
a dictionary and made mainly for automated tools to
recognize associative and commutative terms. The keys
are the terms, and values are the coefficients. The
coefficients are always additive when merging same terms,
i.e. for scalar plus, the coefficients have relation
`<coeff>*<term>`, for scalar mul, the coefficients have
relation `<term>^<coeff>` and for the operator add, the
coefficients have relation `<coeff> * <term>`.

This object also stores an order of the terms, which
is used to print the terms in a canonical order. This
order is not updated automatically, so it is the
responsibility of the user to update the order when
the terms are modified, otherwise the order will be
insertion order.

!!! note
    This type should be treated semantically immutable,
    i.e. the terms should not be modified after creation.
    However, for convenience, we allow the user to modify
    the terms, but the user should be aware that the object
    has immutable semantics.
"""
struct ACSet{K,V} <: AbstractDict{K,V}
    terms::Dict{K,V}
    order::Vector{K}
    is_sorted::Base.RefValue{Bool}
end

"""
$SIGNATURES

Create an empty ACSet.
"""
ACSet{K,V}() where {K,V} = ACSet(Dict{K,V}(), Vector{K}(), Base.RefValue(false))

"""
$SIGNATURES

Create an ACSet from a list of pairs.
"""
function ACSet{K,V}(pairs::Pair...) where {K,V}
    return ACSet{K,V}(pairs)
end

ACSet(pairs::Pair{K,V}...) where {K,V} = ACSet{K,V}(pairs)

"""
$SIGNATURES

Create an ACSet from an iterator of pairs.
"""
function ACSet{K,V}(itr) where {K,V}
    # NOTE: guarantee similar terms are merged
    #       by using setindex instead of create
    #       directly.
    acset = ACSet{K,V}()
    for (key, val) in itr
        acset[convert(K, key)] = convert(V, val)
    end
    return acset
end

"""
$SIGNATURES

Create an ACSet from a dictionary.
"""
function ACSet(terms::Dict{K,V}) where {K,V}
    order = collect(K, keys(terms))
    is_sorted = Base.RefValue(false)
    return ACSet(terms, order, is_sorted)
end

function Base.sort(acset::ACSet; kw...)
    order = if acset.is_sorted[]
        acset.order
    else
        sort(acset.order; kw...)
    end
    return ACSet(acset.terms, order, Base.RefValue(true))
end

function Base.sort!(acset::ACSet; kw...)
    if !acset.is_sorted[]
        sort!(acset.order; kw...)
        acset.is_sorted[] = true
    end
    return acset
end

Base.haskey(acset::ACSet, key) = haskey(acset.terms, key)
Base.getindex(acset::ACSet, key) = acset.terms[key]
function Base.setindex!(acset::ACSet, val, key)
    if haskey(acset.terms, key)
        acset.terms[key] += val
    else
        push!(acset.order, key)
        acset.is_sorted[] = false
        acset.terms[key] = val
    end
    return acset
end

Base.hash(acset::ACSet, h::UInt) = hash(acset.terms, h)

Base.IteratorSize(::Type{<:ACSet}) = Base.HasLength()
Base.IteratorEltype(::Type{<:ACSet}) = Base.HasEltype()
Base.eltype(::Type{ACSet{K,V}}) where {K,V} = Pair{K,V}
Base.length(acset::ACSet) = length(acset.terms)
function Base.iterate(acset::ACSet, state=1)
    if state > length(acset.order)
        return nothing
    end
    key = acset.order[state]
    return key => acset.terms[key], state + 1
end

function lazy_map(f, acset::ACSet)
    return Map(p -> (f(p.first) => p.second))(acset.terms)
end

function Base.map(f, acset::ACSet{K,V}) where {K,V}
    return ACSet{K,V}(lazy_map(f, acset))
end

function Base.mapreduce(f, op, acset::ACSet{K,V}; kw...) where {K,V}
    return foldl(op, MapSplat(f), acset; kw...)
end

function threaded_map(f, acset::ACSet{K,V}) where {K,V}
    return ACSet{K,V}(tcollect(lazy_map(f, acset)))
end

function threaded_map(f, acset::Vector)
    return tcollect(Map(f)(acset))
end

function threaded_map(f, acset::Set)
    return tcollect(Map(f)(acset))
end

function Base.:(==)(lhs::ACSet{K,V}, rhs::ACSet{K,V}) where {K,V}
    return lhs.terms == rhs.terms
end
