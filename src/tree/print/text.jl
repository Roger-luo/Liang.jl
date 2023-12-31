# this is adapted from AbstractTree since
# we need the printing frequently but it kept
# having issues with our case.

struct CharSet
    mid::String
    terminator::String
    skip::String
    dash::String
    trunc::String
    pair::String
end

function CharSet(name::Symbol=:unicode)
    if name == :unicode
        CharSet("├", "└", "│", "─", "⋮", " ⇒ ")
    elseif name == :ascii
        CharSet("+", "\\", "|", "--", "...", " => ")
    else
        throw(ArgumentError("unrecognized dfeault CharSet name: $name"))
    end
end

Base.@kwdef struct Color
    annotation::Symbol = :light_black
end

Base.@kwdef mutable struct State
    depth::Int = 0
    prefix::String = ""
    last::Bool = false
end

struct TextPrinter{IO_t}
    io::IO_t
    charset::CharSet
    max_depth::Int
    color::Color
    state::State
end

function TextPrinter(
    io::IO_t;
    charset::CharSet=CharSet(:unicode),
    max_depth::Int=5,
    color::Color=Color(),
    state=State(),
) where {IO_t}
    return TextPrinter{IO_t}(io, charset, max_depth, color, state)
end

function (p::TextPrinter)(node)
    print(xs...) = Base.print(p.io, xs...)
    println(xs...) = Base.println(p.io, xs...)
    printstyled(xs...; kw...) = Base.printstyled(p.io, xs...; kw...)
    function print_annotation(node, annotation)
        return Print.print_annotation(p.io, node, annotation; color=p.color.annotation)
    end

    node_str = sprint(print_node, node; context=IOContext(p.io))
    node_str *= " " * sprint(print_meta, node; context=IOContext(p.io))
    for (i, line) in enumerate(split(node_str, '\n'))
        i ≠ 1 && print(p.state.prefix::String)
        print(line)
        if !((p.state.depth == 0 || p.state.last) && Tree.is_leaf(node))
            println()
        end
    end

    if p.state.depth > p.max_depth
        println(p.charset.trunc)
        return nothing
    end

    this_print_annotation = should_print_annotation(node)

    children = Iterators.Stateful(Print.children(node))
    annotations = Iterators.Stateful(Print.annotations(node))
    while !isempty(children)
        child_prefix = p.state.prefix::String
        if this_print_annotation
            child = popfirst!(children)
            annotation = popfirst!(annotations)
        else
            child = popfirst!(children)
            annotation = nothing
        end

        print(p.state.prefix::String)

        if isempty(children)
            print(p.charset.terminator)
            child_prefix *= " "^(textwidth(p.charset.skip) + textwidth(p.charset.dash) + 1)

            if p.state.depth > 0 && p.state.last
                is_last_leaf_child = true
            elseif p.state.depth == 0
                is_last_leaf_child = true
            else
                is_last_leaf_child = false
            end
        else
            print(p.charset.mid)
            child_prefix *= p.charset.skip * " "^(textwidth(p.charset.dash) + 1)
            is_last_leaf_child = false
        end

        print(p.charset.dash, ' ')

        if this_print_annotation
            key_str = sprint(Print.print_annotation, node, annotation)
            print_annotation(node, annotation)

            child_prefix *= " "^textwidth(key_str)
        end

        p.state.depth += 1
        parent_last = p.state.last
        p.state.last = is_last_leaf_child
        parent_prefix = p.state.prefix::String
        p.state.prefix = child_prefix::String
        p(child)
        p.state.depth -= 1
        p.state.prefix = parent_prefix::String
        p.state.last = parent_last
    end
end

function text(io::IO, node; kw...)
    return TextPrinter(io; kw...)(node)
end

text(node; kw...) = text(stdout, node; kw...)
