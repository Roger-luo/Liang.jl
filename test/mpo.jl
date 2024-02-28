using Liang.Prelude

function T(i)
    return [
        Op.I[i] Op.Zero[i] Op.Zero[i]
        Op.Z[i] Op.Zero[i] Op.Zero[i]
        Op.Zero[i] Op.Z[i] Op.I[i]
    ]
end

B(i) = [Op.Zero[i] Op.Z[i] Op.I[i]]
BT(i) = [Op.I[i], Op.Z[i], Op.Zero[i]]

B(1) * T(2) * T(3) * BT(4)
