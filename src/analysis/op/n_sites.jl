@data SiteCountErr begin
    NotEqual(Op.Type, Op.Type)
    CannotDetermine(Op.Type)
end

function Base.show(io::IO, err::SiteCountErr.Type)
    @match err begin
        SiteCountErr.NotEqual(lhs, rhs) => print(io, "SiteCountErr.NotEqual($lhs, $rhs)")
        SiteCountErr.CannotDetermine(node) => print(io, "CannotDetermine($node)")
    end
end

@data SiteCount begin
    Adaptive
    Fixed(Int)
    GreaterThan(Int)
    Err(SiteCountErr.Type)
end

@derive SiteCount[PartialEq, Hash]

function Base.show(io::IO, t::SiteCount.Type)
    @match t begin
        SiteCount.Adaptive => print(io, "Adaptive")
        SiteCount.Fixed(n) => print(io, "Fixed($n)")
        SiteCount.GreaterThan(n) => print(io, "GreaterThan($n)")
        SiteCount.Err(err) => print(io, "Err($err)")
    end
end

function Base.:(*)(lhs::SiteCount.Type, rhs::SiteCount.Type)
    @match (lhs, rhs) begin
        (_, SiteCount.Err(_)) => rhs
        (SiteCount.Err(_), _) => lhs
        (SiteCount.Adaptive, _) || (_, SiteCount.Adaptive) => SiteCount.Adaptive

        (SiteCount.Fixed(n), SiteCount.Fixed(m)) => SiteCount.Fixed(n * m)
        (SiteCount.Fixed(n), SiteCount.GreaterThan(m)) => SiteCount.GreaterThan(n * m)
        (SiteCount.GreaterThan(n), SiteCount.Fixed(m)) => SiteCount.GreaterThan(n * m)
        (SiteCount.GreaterThan(n), SiteCount.GreaterThan(m)) => SiteCount.GreaterThan(n * m)
    end
end

function Base.:(+)(lhs::SiteCount.Type, rhs::SiteCount.Type)
    @match (lhs, rhs) begin
        (_, SiteCount.Err(_)) => rhs
        (SiteCount.Err(_), _) => lhs
        (SiteCount.Adaptive, _) || (_, SiteCount.Adaptive) => SiteCount.Adaptive

        (SiteCount.Fixed(n), SiteCount.Fixed(m)) => SiteCount.Fixed(n + m)
        (SiteCount.Fixed(n), SiteCount.GreaterThan(m)) => SiteCount.GreaterThan(n + m)
        (SiteCount.GreaterThan(n), SiteCount.Fixed(m)) => SiteCount.GreaterThan(n + m)
        (SiteCount.GreaterThan(n), SiteCount.GreaterThan(m)) => SiteCount.GreaterThan(n + m)
    end
end

function assert_site_equal(lhs::Op.Type, rhs::Op.Type)
    lhs_sites = n_sites(lhs)
    rhs_sites = n_sites(rhs)
    @match (lhs_sites, rhs_sites) begin
        (SiteCount.Adaptive, SiteCount.Adaptive) => SiteCount.Adaptive
        (SiteCount.Adaptive, SiteCount.Fixed(n)) => SiteCount.Fixed(n)
        (SiteCount.Adaptive, SiteCount.GreaterThan(n)) => SiteCount.GreaterThan(n)

        (SiteCount.Fixed(n), SiteCount.Adaptive) => SiteCount.Fixed(n)
        (SiteCount.Fixed(n), SiteCount.Fixed(m)) => if n == m
            SiteCount.Fixed(n)
        else
            SiteCount.Err(SiteCountErr.NotEqual(lhs, rhs))
        end
        (SiteCount.Fixed(n), SiteCount.GreaterThan(m)) => if n >= m
            SiteCount.Fixed(n)
        else
            SiteCount.Err(SiteCountErr.NotEqual(lhs, rhs))
        end

        (SiteCount.GreaterThan(n), SiteCount.Adaptive) => SiteCount.GreaterThan(n)
        (SiteCount.GreaterThan(n), SiteCount.Fixed(m)) => if m >= n
            SiteCount.Fixed(m)
        else
            SiteCount.Err(SiteCountErr.NotEqual(lhs, rhs))
        end
        (SiteCount.GreaterThan(n), SiteCount.GreaterThan(m)) =>
            SiteCount.GreaterThan(max(n, m))

        (_, SiteCount.Err(_)) || (SiteCount.Err(_), _) => rhs_sites
    end
end

function n_sites(node::Op.Type)
    @match node begin
        Op.Zero => SiteCount.Adaptive
        Op.I || Op.X || Op.Y || Op.Z => SiteCount.Adaptive
        Op.Sx || Op.Sy || Op.Sz => SiteCount.Fixed(1)
        Op.H || Op.T => SiteCount.Fixed(1)
        Op.Constant(x) => n_sites(x)
        Op.Variable(_) => SiteCount.Adaptive
        Op.Add(terms) => reduce(assert_site_equal, keys(terms))
        Op.Mul(lhs, rhs) => assert_site_equal(lhs, rhs)
        Op.Kron(lhs, rhs) => n_sites(lhs) + n_sites(rhs)
        Op.Comm(base, op) || Op.AComm(base, op) => assert_site_equal(base, op)
        Op.Pow(base) => n_sites(base)
        Op.KronPow(base, Index.Constant(n)) => n_sites(base)^n
        Op.KronPow(base, _) => SiteCount.Err(SiteCountErr.CannotDetermine(node))
        Op.Adjoint(op) => n_sites(op)
        Op.TimeOrdered(op, _) => n_sites(op)
        Op.Subscript(_, indices) => SiteCount.GreaterThan(length(indices))
        Op.Sum(region) => SiteCount.Fixed(n_sites(region))
        Op.Prod(region) => SiteCount.Fixed(n_sites(region))
        Op.Exp(op) => n_sites(op)
        Op.Log(op) => n_sites(op)
        Op.Inv(op) => n_sites(op)
        Op.Sqrt(op) => n_sites(op)
        Op.Conj(op) => n_sites(op)
        Op.Transpose(op) => n_sites(op)
        Op.Outer(lhs, rhs) => assert_site_equal(lhs, rhs)
        Op.Annotate(op, basis) => n_sites(basis.space)
    end
end

function n_sites(node::Space.Type)
    @match node begin
        Space.Product(lhs, rhs) => n_sites(lhs) + n_sites(rhs)
        Space.Pow(base, exp) => n_sites(base) * exp
        Space.Subspace(space) => n_sites(space)
        _ => SiteCount.Fixed(1)
    end
end
