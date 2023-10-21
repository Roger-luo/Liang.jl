using Liang.Data.Prelude
using Liang.Match: expr2pattern, EmitInfo, PatternInfo

pat = expr2pattern(:((x, xs::Int...)))
variant_type(pat.xs[2])


info = EmitInfo(Main, :x, quote
    (x, xs...) => xs
    (x, xs..., y) => xs
    (x, xs..., 1) => xs
    (x, xs..., y, z) => xs
end)

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[1])(:x)

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[2])(:x)
pinfo.scope

pinfo = PatternInfo(info)
Match.decons(pinfo, info.patterns[3])(:x)
pinfo.scope
