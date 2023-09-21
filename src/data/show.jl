struct FormatPrinter{IO_t, Indent, Leading, Print, PrintLn, Unquoted, Show, Sep}
    io::IO_t
    indent::Indent
    leading::Leading
    print::Print
    println::PrintLn
    unquoted::Unquoted
    show::Show
    sep::Sep
end

function FormatPrinter(io::IO)
    indent(n::Int) = Base.print(io, ' ' ^ n)
    leading() = indent(get(io, :indent, 0))
    print(xs...; kw...) = Base.printstyled(io, xs...; kw...)
    println(xs...; kw...) = begin
        Base.printstyled(io, xs..., '\n'; kw...)
        leading()
    end
    print_unquoted(xs...; kw...) = print(Base.sprint(Base.show_unquoted, xs...); kw...)
    show(mime, x) = Base.show(io, mime, x)
    show(x) = Base.show(io, x)

    function sep(left, right, trim::Int = 20)
        _, width = displaysize(io)
        width = min(width, 80)
        nindent = get(io, :indent, 0)
        ncontent = textwidth(string(left)) - textwidth(string(right))
        nsep = max(0, width - nindent - trim - ncontent)
        print(" ", "-"^nsep, " "; color=:light_black)
    end

    FormatPrinter(io,
        indent, leading,
        print, println,
        print_unquoted,
        show, sep
    )
end

function indent(f::FormatPrinter, n::Int = 4)
    FormatPrinter(IOContext(f.io, :indent=>get(f.io, :indent, 0) + n))
end

function Base.show(io::IO, ::MIME"text/plain", var::TypeVar)
    isnothing(var.lower) || printstyled(io, var.lower, " <: "; color=:light_cyan)
    printstyled(io, var.name; color=:light_cyan)
    isnothing(var.upper) || printstyled(io, " <: ", var.upper; color=:light_cyan)
end

function Base.show(io::IO, ::MIME"text/plain", var::Variant)
    f = FormatPrinter(io)
    f.leading()
    isnothing(var.source) || f.println(var.source; color=:light_black)
    if var.kind === Named
        var.is_mutable && f.print("mutable "; color=:red)
        f.print("struct "; color=:red)
        f.print(var.name)

        ff = indent(f)
        for field in var.fields::Vector{NamedField}
            ff.println()
            isnothing(field.source) || (ff.println(field.source; color=:light_black))
            ff.print(field.name)
            ff.print("::"; color=:red)
            ff.unquoted(field.type; color=:light_cyan)
            if field.default !== no_default
                ff.print(" = "; color=:red)
                ff.unquoted(field.default; color=:light_cyan)
            end
        end
        f.println()
        f.print("end"; color=:red)
    elseif var.kind === Anonymous
        f.print(var.name)
        f.print('('; color=:red)
        fields = var.fields::Vector{Field}
        if !isempty(fields)
            f.unquoted(fields[1].type; color=:light_cyan)
            for each in fields[2:end]
                f.print(", ")
                f.unquoted(each.type; color=:light_cyan)
            end
        end
        f.print(')'; color=:red)
    else # Singleton
        f.print(var.name)
    end
end

function Base.show(io::IO, mime::MIME"text/plain", def::TypeDef)
    f = FormatPrinter(io); f.leading()

    isnothing(def.source) || f.println(def.source; color=:light_black)
    f.print("@data "; color=:red)
    f.print(def.name)

    if !isnothing(def.supertype)
        f.print(" <: "; color=:red)
        f.unquoted(def.supertype; color=:light_cyan)
    end

    f.println(" begin"; color=:red)
    vf = indent(f)
    for (idx, each) in enumerate(def.variants)
        vf.show(mime, each)

        if idx < length(def.variants)
            vf.println()
        end
    end
    f.println()
    f.print("end"; color=:red)
end # function Base.show
