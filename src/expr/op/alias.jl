const Qubit = Basis(Op.Z, Space.Qubit)

function Qudit(d::Int)
    return Basis(Op.Z, Space.Qudit(d))
end
