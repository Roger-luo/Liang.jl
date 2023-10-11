using Liang.Match: Pattern


Pattern.Call(
    Pattern.Dot(Pattern.Constant(:Scalar), Pattern.Constant(:Pow)),
    [
        Pattern.Variable(:x),
        Pattern.Constant(2),
    ],
    Dict(),
)

Pattern.Comprehension(
    Pattern.VCat([Pattern.Variable(:a), Pattern.Variable(:b)]),
    [:a, :b],
    [Pattern.Constant(1:10), Pattern.Constant(1:10)],
    nothing,
)
Pattern.VCat([Pattern.Variable(:a), Pattern.Variable(:b)])
Pattern.Constant(1:10)
