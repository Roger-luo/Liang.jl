@data BasisInfo begin
    Adaptive
    Required
    Fixed(Basis)
    Product(Vector{Basis})

    struct Err
        msg::String
        meta::Any = nothing
    end
end

@derive BasisInfo[PartialEq, Hash, Show]

function Base.convert(::Type{Basis}, info::BasisInfo.Type)
    @match info begin
        BasisInfo.Fixed(basis) => return basis
        BasisInfo.Product(xs) => begin
            length(xs) == 1 && return xs[1]
            return reduce(*, xs)
        end
        _ => error("expect fixed basis, got: $info")
    end
end

function union_basis(lhs::BasisInfo.Type, rhs::BasisInfo.Type)
    @match (lhs, rhs) begin
        (BasisInfo.Err(_), _) => lhs
        (_, BasisInfo.Err(_)) => rhs
        (BasisInfo.Product(xs), BasisInfo.Product(ys)) => begin
            length(lhs) == length(rhs) ||
                return BasisInfo.Err("length of lhs and rhs mismatch")

            new_basis = BasisInfo.Type[]
            sizehint!(new_basis, length(lhs))
            for (idx, (x, y)) in enumerate(zip(lhs, rhs))
                x = union_basis(x, y)
                isa_variant(x, BasisInfo.Err) &&
                    return BasisInfo.Err("lhs[$idx] and rhs[$idx] mismatch")
                push!(new_basis, x)
            end
            return BasisInfo.Product(new_basis)
        end

        (x, x) => x
        (BasisInfo.Adaptive, other) || (other, BasisInfo.Adaptive) => other
        (BasisInfo.Required, other) || (other, BasisInfo.Required) => other # Fixed or Required
        _ => BasisInfo.Err("basis mismatch, got: $lhs and $rhs")
    end
end

function add_basis(op)
    it = Iterators.Stateful(Tree.children(op))
    x_term = popfirst!(it)
    x_basis = basis(x_term)
    x_hash = hash(x_basis)

    while !isempty(it)
        y_term = popfirst!(it)
        y_basis = basis(y_term)
        y_hash = hash(y_basis)
        x_hash == y_hash && continue

        # not naively equal, try union
        guess_basis = union_basis(x_basis, y_basis)
        hash_guess_basis = hash(guess_basis)

        @match guess_basis begin
            BasisInfo.Err(msg) => return BasisInfo.Err(msg, op)
            _ => nothing
        end

        x_basis = guess_basis
    end
    return x_basis
end

function Base.:(*)(lhs::BasisInfo.Type, rhs::BasisInfo.Type)
    @match (lhs, rhs) begin
        (BasisInfo.Product(xs), BasisInfo.Product(ys)) => BasisInfo.Product(vcat(xs, ys))
        (BasisInfo.Product(xs), _) => BasisInfo.Product(vcat(xs, [rhs]))
        (_, BasisInfo.Product(ys)) => BasisInfo.Product(vcat([lhs], ys))
        _ => BasisInfo.Product([lhs, rhs])
    end
end

function Base.:(^)(base::BasisInfo.Type, exp::Index.Type)
    @match exp begin
        Index.Constant(idx) => BasisInfo.Product(fill(base, idx))
        _ => BasisInfo.Err("expect constant index", exp)
    end
end

"""
$SIGNATURES

Infer the basis of an expression.
"""
function basis(node::Op.Type)
    @match node begin
        Op.Zero ||
            Op.I ||
            Op.X ||
            Op.Y ||
            Op.Z ||
            Op.Sx ||
            Op.Sy ||
            Op.Sz ||
            Op.H ||
            Op.T => BasisInfo.Adaptive

        Op.Constant(_) => BasisInfo.Required
        Op.Variable(_) => BasisInfo.Adaptive
        Op.Add(_) => add_basis(node)
        Op.Mul(lhs, rhs) => union_basis(basis(lhs), basis(rhs))
        Op.Kron(lhs, rhs) => basis(lhs) * basis(rhs)
        Op.Comm(base, op) || Op.AComm(base, op) => union_basis(basis(base), basis(op))
        Op.Pow(base) => basis(base)
        Op.KronPow(base, exp) => basis(base)^exp
        Op.Adjoint(op) => basis(op)
        Op.TimeOrdered(op) => basis(op)
        Op.Subscript(op) => BasisInfo.Required
        Op.Sum(_) => sum_basis(node)
        Op.Prod(_) => prod_basis(node)
        Op.Exp(op) => basis(op)
        Op.Log(op) => basis(op)
        Op.Inv(op) => basis(op)
        Op.Sqrt(op) => basis(op)
        Op.Conj(op) => basis(op)
        Op.Transpose(op) => basis(op)
        Op.Outer(lhs, rhs) => union_basis(basis(lhs), basis(rhs))
        Op.Annotate(_, op_basis) => BasisInfo.Fixed(op_basis)
    end
end

function sum_basis(node::Op.Type)
    return error("not implemented yet")
    # @match node Op.Sum(region, indices, term) => (region, indices, term)
end

function prod_basis(node::Op.Type)
    return error("not implemented yet")
end

function basis(node::State.Type)
    @match node begin
        State.Zero => BasisInfo.Adaptive
        State.Eigen(op::Op.Type, _) => basis(op)
        State.Product(_) => BasisInfo.Required
        State.Kron(lhs, rhs) => basis(lhs) * basis(rhs)
        State.Add(_) => add_basis(node)
        State.Annotate(_, st_basis) => BasisInfo.Fixed(st_basis)
    end
end

"""
$SIGNATURES

Propagate basis information from the root node to the leaf nodes
by creating `Op.Annotate` nodes on leaf nodes.
"""
function propagate_basis(node::Op.Type, info::BasisInfo.Type)
    @match info begin
        BasisInfo.Adaptive => return node
        BasisInfo.Required => return node
        BasisInfo.Err(_) => return node
        _ => nothing # propagate
    end

    @match node begin
        if Tree.is_leaf(node)
        end => Op.Annotate(node, info)
        Op.Kron(lhs, rhs) => propagate_basis_kron(node, info, lhs, rhs)
        Op.KronPow(base, exp) => propgate_basis_kron_pow(node, info, base, exp)

        # these expression are treated as leaf nodes
        # as it's not beneficial to propagate basis information
        Op.Subscript(_) => Op.Annotate(node, info)
        Op.Sum(_) => Op.Annotate(node, info)
        Op.Prod(_) => Op.Annotate(node, info)
        Op.Outer(lhs, rhs) => Op.Annotate(node, info)
        Op.Annotate(_) => node

        # nodes that inherit basis from their parent
        _ => Tree.map_children(node) do term
            propagate_basis(term, info)
        end
    end
end

function propgate_basis_kron_pow(
    node::Op.Type, info::BasisInfo.Type, base::Op.Type, exp::Op.Type
)
    isa_variant(node, Op.KronPow) || error("expect Op.KronPow, got: $node")

    @match info begin
        BasisInfo.Fixed(basis) => return Op.Annotate(node, basis)
        BasisInfo.Product(bases) => begin
            base_n_sites = @match n_sites(base) begin
                SiteCount.Fixed(n) => n
                _ => error("expect fixed site count, got: $base")
            end
            return Op.KronPow(
                propagate_basis(base, BasisInfo.Product(bases[1:base_n_sites])), exp
            )
        end
    end
end

function propagate_basis_kron(
    node::Op.Type, info::BasisInfo.Type, lhs::Op.Type, rhs::Op.Type
)
    @match info begin
        BasisInfo.Fixed(basis) => return Op.Annotate(node, basis)
        BasisInfo.Product(bases) => begin
            lhs_n_sites = @match n_sites(lhs) begin
                SiteCount.Fixed(n) => n
                _ => error("expect fixed site count, got: $lhs")
            end
            return Op.Kron(
                propagate_basis(lhs, BasisInfo.Product(bases[1:lhs_n_sites])),
                propagate_basis(rhs, BasisInfo.Product(bases[(lhs_n_sites + 1):end])),
            )
        end
    end
end
