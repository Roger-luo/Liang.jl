function Data.show_data(io::IO, x::Pattern.Type)
    f = Data.FormatPrinter(io)
    if isa_variant(x, Pattern.Wildcard)
        f.print("_"; color=:red)
    elseif isa_variant(x, Pattern.Variable)
        f.print(x.:1; color=:blue)
    elseif isa_variant(x, Pattern.Quote)
        if x.:1 isa Union{Symbol, Expr}
            f.print("\$(", x.:1, ")")
        else
            f.print(x.:1)
        end
    elseif isa_variant(x, Pattern.And)
        f.print("(")
        f.show(x.:1)
        f.print(") && ("; color=:red)
        f.show(x.:2)
        f.print(")")
    elseif isa_variant(x, Pattern.Ref)
        f.print("\$(", x.head, ")")
        f.print("[")
        for (idx, arg) in enumerate(x.args)
            idx > 1 && f.print(", ")
            f.show(arg)
        end
        f.print("]")
    elseif isa_variant(x, Pattern.Call)
        if x.head === :(:)
            for (idx, each) in enumerate(x.args)
                idx > 1 && f.print(":")
                f.show(each)
            end
        # some common infix operators
        elseif x.head in (:(+), :(-), :(*), :(/), :(\))
            f.show(x.args[1])
            f.print(" ", x.head, " ")
            f.show(x.args[2])
        else
            f.print("\$(", x.head, ")")
            f.print("(")
            for (idx, arg) in enumerate(x.args)
                idx > 1 && f.print(", ")
                f.show(arg)
            end
            if !isempty(x.kwargs)
                f.print("; ")
                for (idx, (key, val)) in enumerate(x.kwargs)
                    idx > 1 && f.print(", ")
                    f.print(key, "=", val)
                end
            end
            f.print(")")
        end
    elseif isa_variant(x, Pattern.Tuple)
        f.print("(")
        for (idx, arg) in enumerate(x.xs)
            idx > 1 && f.print(", ")
            f.show(arg)
        end
        f.print(")")
    elseif isa_variant(x, Pattern.NamedTuple)
        f.print("(")
        for (idx, arg) in enumerate(x.xs)
            idx > 1 && f.print(", ")
            f.print(x.names[idx], "=", arg)
        end
        f.print(")")
    elseif isa_variant(x, Pattern.Vector)
        f.print("[")
        for (idx, arg) in enumerate(x.xs)
            idx > 1 && f.print(", ")
            f.show(arg)
        end
        f.print("]")
    elseif isa_variant(x, Pattern.Row)
        for (idx, arg) in enumerate(x.xs)
            idx > 1 && f.print(" ")
            f.show(arg)
        end
    elseif isa_variant(x, Pattern.NRow)
        for (idx, arg) in enumerate(x.xs)
            idx > 1 && f.print(";"^x.n)
            f.show(arg)
        end
    elseif isa_variant(x, Pattern.VCat)
        show_vcat(f, x)
    elseif isa_variant(x, Pattern.HCat)
        show_hcat(f, x)
    elseif isa_variant(x, Pattern.NCat)
        show_ncat(f, x)
    elseif isa_variant(x, Pattern.TypedVCat)
        f.print(x.type; color=:light_cyan)
        show_vcat(f, x)
    elseif isa_variant(x, Pattern.TypedHCat)
        f.print(x.type; color=:light_cyan)
        show_hcat(f, x)
    elseif isa_variant(x, Pattern.TypedNCat)
        f.print(x.type; color=:light_cyan)
        show_ncat(f, x)
    elseif isa_variant(x, Pattern.Splat)
        f.show(x.body)
        f.print("...")
    elseif isa_variant(x, Pattern.TypeAnnotate)
        f.show(x.body)
        f.print("::")
        f.print(x.type; color=:light_cyan)
    elseif isa_variant(x, Pattern.Generator)
        f.show(x.body)
        f.print(" for ")
        for (idx, (var, iter)) in enumerate(zip(x.vars, x.iterators))
            idx > 1 && f.print(", ")
            f.print(var)
            f.print(" in ")
            f.show(iter)
        end

        if !isnothing(x.filter)
            f.print(" if ")
            f.show(x.filter)
        end
    elseif isa_variant(x, Pattern.Comprehension)
        f.print("[")
        f.show(x.body)
        f.print("]")
    else
        error("unknown pattern type: ", x)
    end
end

function show_vcat(f::Data.FormatPrinter, x::Pattern.Type)
    f.print("[")
    for (idx, arg) in enumerate(x.xs)
        idx > 1 && f.print("; ")
        f.show(arg)
    end
    f.print("]")
end

function show_hcat(f::Data.FormatPrinter, x::Pattern.Type)
    f.print("[")
    for (idx, arg) in enumerate(x.xs)
        idx > 1 && f.print(" ")
        f.show(arg)
    end
    f.print("]")
end

function show_ncat(f::Data.FormatPrinter, x::Pattern.Type)
    f.print("[")
    for (idx, arg) in enumerate(x.xs)
        idx > 1 && f.print(";"^x.n)
        f.show(arg)
    end
    f.print("]")
end
