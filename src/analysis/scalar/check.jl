function is_const(node::Index.Type)
    @match node begin
        Index.Constant(_) => true
        _ => false
    end
end
