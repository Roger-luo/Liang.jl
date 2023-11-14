using Liang.Data.Prelude
using Liang.Match: Match, expr2pattern, EmitInfo, PatternInfo

info = EmitInfo(
    Main,
    :x,
    quote
        [x, xs...] => xs
        [x, xs..., y] => xs
        [x, xs..., 1] => xs
        [x, xs..., y, z] => xs
        [x, xs::Int..., y, z] => xs
        [x, (y, z)...] => (y, z)
        [x, xs..., x] => x
    end,
)

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[1])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[2])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[3])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[4])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[5])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[6])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[7])(:x)
pinfo.scope
