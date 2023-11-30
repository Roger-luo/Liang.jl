function parse_var(f, s::AbstractString)
    if (m = match(r"%([0-9]+)", s); !isnothing(m))
        id = parse(Int64, m.captures[1])
        id > 0 || error("invalid SSA id: $id ≤ 0")
        return f(Variable.SSA(id))
    elseif m == "_"
        return f(Variable.Wildcard)
    elseif startswith(s, "\$")
        return f(Variable.Match(Symbol(s[2:end])))
    else
        return f(Variable.Slot(Symbol(s)))
    end
end
