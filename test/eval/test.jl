
using Liang: Scalar, Num, Variable
using Liang.Match: @match
using Liang.Data: @data
using Liang.Eval: interp




a = Scalar.Variable(Variable.Slot(:a))
c = Scalar.Variable(Variable.Slot(:c))
b = convert(Scalar.Type, 4)

expr = a * c / b + 3



interp(Dict(Variable.Slot(:a) => 2, Variable.Slot(:c) => 4), expr * Scalar.Pi)