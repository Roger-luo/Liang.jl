function n_sites(node::Op.Type)
    @match node begin
        Op.Zero => 1
        Op.I => 1
    end
end
