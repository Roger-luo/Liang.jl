mutable struct BasisAnalysis
    n_sites::Int
    basis::Vector{Basis}
    sites::Vector{UnitRange{Int}} # continuous range of sites
end

BasisAnalysis() = BasisAnalysis(0, [], [])

function (anlys::BasisAnalysis)(node::Op.Type) end
