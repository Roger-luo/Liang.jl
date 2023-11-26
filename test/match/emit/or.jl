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
