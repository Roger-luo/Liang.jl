using Liang.Data.Prelude
using Liang.Match: @match, Match, expr2pattern, EmitInfo, PatternInfo

@match 1.0 begin
    x::Int || x::Float64 => x
end

info = EmitInfo(
    Main,
    :x,
    quote
        x::Int || x::Float64 => x
        y::Float64 => y
    end,
)

pinfo = PatternInfo(info)
Match.decons(pinfo, info.cases[1])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.cases[2])(:x)
pinfo.scope

using Liang.Prelude

info = EmitInfo(
    Main,
    :x,
    quote
        (Index.Constant(x), y) || (y, Index.Constant(x)) => Index.Mul(x, ACSet(y => 1))
    end,
)

pinfo = PatternInfo(info)
Match.decons(pinfo, info.cases[1])(:x)
pinfo.scope
