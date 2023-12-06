using Liang.Prelude
using Liang.Analysis.OpAnalysis: basis, n_sites, propagate_basis
Qubit_Z = Basis(Op.Z, Space.Qubit)
Qubit_X = Basis(Op.X, Space.Qubit)

t1 = canonicalize(Op.I + kron(Op.Annotate(Op.X, Qubit_Z), Op.Annotate(Op.Z, Qubit_X)))
n_sites(t1)
basis(t1)
propagate_basis(t1, basis(t1))

t2 = kron(Op.I, Op.X) + kron(Op.X % Qubit, Op.Z % Spin(3))
propagate_basis(t2, basis(t2))
