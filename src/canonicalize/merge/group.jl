function merge_group_element(node::Op.Type)
    @match node begin
        Op.Comm(base, Op.Comm(base, A, pow1), pow2) =>
            Op.Comm(base, A, canonicalize(pow1 + pow2))
        Op.AComm(base, Op.AComm(base, A, pow1), pow2) =>
            Op.AComm(base, A, canonicalize(pow1 + pow2))
        _ => node
    end
end
