function emit(info::EmitInfo)
    matches = expr_map(info.patterns, info.exprs) do pat, expr
        cond, assigns = emit_decons(info, pat)

        quote
            if $cond
                $(info.return_var) = let $(assigns...)
                    $expr
                end
                @goto $(info.final_label)
            end
        end
    end

    quote
        $(info.value_holder) = $(info.value)
        $matches
        @label $(info.final_label)
        $(info.return_var)
    end
end

and_expr(lhs, rhs) = quote
    $lhs && $rhs
end

struct PatternInfo
    emit::EmitInfo
    scope::Dict{Symbol, Set{Symbol}}
end

PatternInfo(info::EmitInfo) = PatternInfo(info, Dict{Symbol, Set{Symbol}}())

function Base.setindex!(info::PatternInfo, v::Symbol, k::Symbol)
    push!(get!(Set{Symbol}, info.scope, k), v)
    return info
end

include("decons.jl")
include("leafs.jl")
include("logic.jl")
include("call.jl")
include("tuple.jl")

function decons_type_annotate(info::PatternInfo, pat::Pattern.Type)
    return function annotate(value)
        and_expr(
            :($value isa $(pat.type)),
            decons(info, pat.body)(value)
        )
    end
end
