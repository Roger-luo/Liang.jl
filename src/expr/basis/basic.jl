function n_levels(space::Space.Type)
    @match space begin
        Space.Qubit => 2
        Space.Qudit(d) => d
        Space.Spin(d) => d
        Space.Product(s1, s2) => n_levels(s1) * n_levels(s2)
        Space.Pow(s, n) => n_levels(s)^n
        Space.Subspace(s, v) => length(v)
        Space.GKP => error("GKP space is not supported yet")
        Space.Gaussian => error("Gaussian space is not supported yet")
        Space.Fermion(d) => error("Fermion space is not supported yet")
        Space.Anyon(d, f) => error("Anyon space is not supported yet")
        Space.Fock => error("Fock space is not supported yet")
    end
end
