# NOTE: rewrite rule only happens within the same
# data type to maintain type stability
struct Rule{E}
    from::E
    to::E
end

"""
$SIGNATURES

Substitute `Match` in `expr` with the corresponding
expression value defined in `assigns`. Values must be
the same expression type.
"""
function subtitute(expr::E, assigns::Dict{E,E}) where {E} end

"""
$SIGNATURES

Match `expr` with `pattern`.
"""
function match(expr::E, pattern::E) where {E} end

"""
$SIGNATURES

Rewrite `expr` with `rule`.
"""
function (rule::Rule{E})(expr::E) where {E} end
