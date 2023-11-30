function fold_const_pow(node::Scalar.Type)
    @match node begin
        Scalar.Pow(Scalar.Constant(x), Scalar.Constant(y)) => return Scalar.Constant(x^y)
        _ => return node
    end
end
