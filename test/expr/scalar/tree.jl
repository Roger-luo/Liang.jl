using Liang.Expression: Scalar, Num, Index, @scalar_str, @index_str
using Liang.Match: @match
using Liang.Tree

ex1 = (index"i" + 2) * index"j"
ex2 = index"i" + 2 * index"j"^3

Tree.inline_print(stdout, ex2)

ex3 = abs(scalar"i" + 2 * scalar"j"^3)^2

Tree.inline_print(stdout, ex3)
