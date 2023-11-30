using Liang.Prelude

canonicalize(Op.I + kron(Op.Annotate(Op.X, Qubit), Op.Z))
