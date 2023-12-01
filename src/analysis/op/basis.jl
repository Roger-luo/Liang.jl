@data SiteRange begin
    Adaptive # e.g Op.I adaptive to other expression
    Segment(Int, Int)
end

@derive SiteRange[PartialEq, Hash]

struct BasisAnalysis
    # TODO: replace with a segment/interval tree
    data::Dict{SiteRange,Basis}
end

# function (anlysis::BasisAnalysis)(node::Op.Type, )
#     @match node begin
#         Op.Annotate(_, basis) =>
#     end
# end
