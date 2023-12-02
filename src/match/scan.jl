struct EmitInfo
    mod::Module
    value::Any
    cases::Vector{Pattern.Type}
    exprs::Vector{Any}
    value_holder::Symbol
    final_label::Symbol
    return_var::Symbol
    source
end

function EmitInfo(mod::Module, value, body, source=nothing)
    # single pattern
    if Meta.isexpr(body, :call) && body.args[1] === :(=>)
        cases = [expr2pattern(body.args[2])]
        exprs = [body.args[3]]
    elseif Meta.isexpr(body, :block)
        line_info = source
        cases = Pattern.Type[]
        exprs = Any[]
        for stmt in body.args
            if stmt isa LineNumberNode
                line_info = stmt
            elseif Meta.isexpr(stmt, :call) && stmt.args[1] === :(=>)
                push!(cases, warn_expr2pattern(mod, stmt.args[2]))
                push!(exprs, stmt.args[3])
            else
                throw(SyntaxError("invalid pattern table: $body"; source=line_info))
            end
        end
    else
        throw(SyntaxError("invalid pattern table: $body"; source))
    end

    return EmitInfo(
        mod, value, cases, exprs, gensym("value"), gensym("final"), gensym("return"), source
    )
end

function warn_expr2pattern(mod::Module, expr)
    if expr isa Symbol && isdefined(mod, expr)
        @warn "you are using a variable name that is already defined in the module: $(expr)"
    end
    return expr2pattern(expr)
end

function split_toplevel_or(cases::Vector{Pattern.Type}, exprs::Vector{Any})
    new_cases, new_exprs = Pattern.Type[], []
    for (case, expr) in zip(cases, exprs)
        if isa_variant(case, Pattern.Or)
            push!(new_cases, case.:1)
            push!(new_exprs, expr)
            push!(new_cases, case.:2)
            push!(new_exprs, expr)
        else
            push!(new_cases, case)
            push!(new_exprs, expr)
        end
    end
    return new_cases, new_exprs
end

function expr2pattern(expr)
    expr === :_ && return Pattern.Wildcard
    expr isa Symbol && return Pattern.Variable(expr)
    expr isa Expr || return Pattern.Quote(expr)

    head = expr.head
    head === :$ && return quote2pattern(expr)
    head === :(&&) && return and2pattern(expr)
    head === :(||) && return or2pattern(expr)
    head === :if && return if2pattern(expr)
    head === :ref && return ref2pattern(expr)
    head === :call && return call2pattern(expr)
    head === :. && return dot2pattern(expr)
    head === :(::) && return type2pattern(expr)
    head === :(=) && return kw2pattern(expr)
    head === :tuple && return tuple2pattern(expr)
    head === :vect && return vect2pattern(expr)
    head === :vcat && return vcat2pattern(expr)
    head === :hcat && return hcat2pattern(expr)
    head === :ncat && return ncat2pattern(expr)
    head === :typed_vcat && return typed_vcat2pattern(expr)
    head === :typed_hcat && return typed_hcat2pattern(expr)
    head === :typed_ncat && return typed_ncat2pattern(expr)
    head === :row && return row2pattern(expr)
    head === :nrow && return nrow2pattern(expr)
    head === :... && return splat2pattern(expr)
    head === :comprehension && return comprehension2pattern(expr)
    head === :generator && return generator2pattern(expr)

    return error("unsupported expression: $(expr)")
end

function quote2pattern(expr)
    return Pattern.Quote(expr.args[1])
end

function and2pattern(expr)
    return Pattern.And(expr2pattern(expr.args[1]), expr2pattern(expr.args[2]))
end

function or2pattern(expr)
    return Pattern.Or(expr2pattern(expr.args[1]), expr2pattern(expr.args[2]))
end

function if2pattern(expr)
    cond = expr.args[1] # just ignore body
    return Pattern.Guard(cond)
end

function generator2pattern(expr)
    body = expr2pattern(expr.args[1])
    if Meta.isexpr(expr.args[2], :filter) # contains if
        filter = expr2pattern(expr.args[2].args[1])
        stmts = expr.args[2].args[2:end]
    else # just plain generator
        filter = nothing
        stmts = expr.args[2:end]
    end

    vars, iterators = Symbol[], Pattern.Type[]
    for each in stmts
        key, it = each.args
        push!(vars, key)
        push!(iterators, expr2pattern(it))
    end
    return Pattern.Generator(body, vars, iterators, filter)
end

function ref2pattern(expr)
    return Pattern.Ref(expr.args[1], expr2pattern.(expr.args[2:end]))
end

function comprehension2pattern(expr)
    return Pattern.Comprehension(generator2pattern(expr.args[1]))
end

function splat2pattern(expr)
    return Pattern.Splat(expr2pattern(expr.args[1]))
end

function ncat2pattern(expr)
    return Pattern.NCat(expr.args[1], expr2pattern.(expr.args[2:end]))
end

function hcat2pattern(expr)
    return Pattern.HCat(expr2pattern.(expr.args))
end

function vcat2pattern(expr)
    return Pattern.VCat(expr2pattern.(expr.args))
end

function typed_ncat2pattern(expr)
    return Pattern.TypedNCat(
        expr.args[1], # type
        expr.args[2], # n
        expr2pattern.(expr.args[2:end]),
    )
end

function typed_hcat2pattern(expr)
    return Pattern.TypedHCat(
        expr.args[1], # type
        expr2pattern.(expr.args[2:end]),
    )
end

function typed_vcat2pattern(expr)
    return Pattern.TypedVCat(
        expr.args[1], # type
        expr2pattern.(expr.args[2:end]),
    )
end

function row2pattern(expr)
    return Pattern.Row(expr2pattern.(expr.args))
end

function nrow2pattern(expr)
    return Pattern.NRow(expr.args[1], expr2pattern.(expr.args[2:end]))
end

function vect2pattern(expr)
    return Pattern.Vector(expr2pattern.(expr.args))
end

function tuple2pattern(expr)
    return Pattern.Tuple(expr2pattern.(expr.args))
end

function kw2pattern(expr)
    return Pattern.Kw(expr.args[1], expr2pattern(expr.args[2]))
end

function type2pattern(expr)
    if length(expr.args) == 1
        return Pattern.TypeAnnotate(Pattern.Wildcard, expr.args[1])
    else
        return Pattern.TypeAnnotate(expr2pattern(expr.args[1]), expr.args[2])
    end
end

function dot2pattern(expr)
    # NOTE: let's assume all dot expression
    # refers to some existing module/struct object
    # so they gets eval-ed later in the generated
    # code
    return Pattern.Quote(expr)
end

function call2pattern(expr)
    args = Pattern.Type[]
    kwargs = Dict{Symbol,Pattern.Type}()
    if Meta.isexpr(expr.args[2], :parameters)
        for each in expr.args[2].args
            if each isa Symbol
                key, val = (each, each)
            else
                key, val = each.args
            end
            kwargs[key] = expr2pattern(val)
        end
    else
    end

    for each in expr.args[2:end]
        Meta.isexpr(each, :parameters) && continue
        if Meta.isexpr(each, :kw)
            key, val = each.args
            kwargs[key] = expr2pattern(val)
        else
            push!(args, expr2pattern(each))
        end
    end

    # NOTE: might need to eval this?
    return Pattern.Call(expr.args[1], args, kwargs)
end
