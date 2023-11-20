struct Fixpoint{R}
    map::R
    max_iter::Int
end

"""
$SIGNATURES

Create a fixpoint rewriter.
"""
function Fixpoint(f; max_iter::Int=1000)
    return Fixpoint(f, max_iter)
end

function (p::Fixpoint)(x)
    y = p.map(x)
    for _ in 1:rw.max_iter
        x === y && return x # rule return the same object
        x == y && return x # rule return the equal value
        isnothing(y) && return x # rule terminates

        x = y
        y = p.map(x)
    end
    @debug "fixpoint reached max iteration"
    return y # return the last result
end
