using Liang.Prelude
using Liang.Analysis.OpAnalysis: basis, n_sites, propagate_basis
t1 = canonicalize(Op.I + kron(Op.Annotate(Op.X, Qubit), Op.Annotate(Op.Z, Qubit)))
n_sites(t1)
basis(t1)
propagate_basis(t1, basis(t1))
