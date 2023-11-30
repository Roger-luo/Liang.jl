Base.show(io::IO, data::Space.Type) = Tree.Print.inline(io, data)

function Base.show(io::IO, node::Basis)
    isempty(node.alias) || return printstyled(io, node.alias; color=:light_black)
    printstyled(io, "Basis("; color=:light_black)
    Tree.Print.inline(io, node.op)
    printstyled(io, ", "; color=:light_black)
    Tree.Print.inline(io, node.space)
    return printstyled(io, ")"; color=:light_black)
end

function Tree.Print.print_node(io::IO, node::Space.Type)
    @match node begin
        Space.Qubit => printstyled(io, "Qubit"; color=:light_black)
        Space.Qudit(d) => printstyled(io, "Qudit($d)"; color=:light_black)
        Space.Spin(d) => begin
            if iseven(d)
                printstyled(io, "Spin($(d÷2))"; color=:light_black)
            else
                printstyled(io, "Spin($d/2)"; color=:light_black)
            end
        end
        Space.Product(s1, s2) => printstyled(io, "⊗"; color=:light_black)
        Space.Pow(s, n) => printstyled(io, "^", n; color=:light_black)
        Space.Subspace(s, v) => begin
            printstyled(io, "["; color=:light_black)
            if length(v) < 4
                for i in 1:length(v)
                    printstyled(io, v[i]; color=:light_black)
                    if i < length(v)
                        printstyled(io, ", "; color=:light_black)
                    end
                end
            else
                for i in 1:2
                    printstyled(io, v[i]; color=:light_black)
                    if i < 2
                        printstyled(io, ", "; color=:light_black)
                    end
                end
                printstyled(io, ", ..., "; color=:light_black)
                for i in (length(v) - 1):length(v)
                    printstyled(io, v[i]; color=:light_black)
                    if i < length(v)
                        printstyled(io, ", "; color=:light_black)
                    end
                end
            end
            printstyled(io, "]"; color=:light_black)
        end
        Space.GKP => printstyled(io, "GKP"; color=:light_black)
        Space.Gaussian => printstyled(io, "Gaussian"; color=:light_black)
        Space.Fermion(d) => printstyled(io, "Fermion($d)"; color=:light_black)
        Space.Anyon(d, f) => printstyled(io, "Anyon($d, $f)"; color=:light_black)
        Space.Fock => printstyled(io, "Fock"; color=:light_black)
    end
end

function Tree.Print.precedence(node::Space.Type)
    @match variant_type(node) begin
        Space.Product => 1
        Space.Pow => 2
        _ => 0
    end
end

function Tree.Print.is_infix(node::Space.Type)
    @match node begin
        Space.Product(_, _) => true
        _ => false
    end
end

function Tree.Print.is_postfix(node::Space.Type)
    @match node begin
        Space.Subspace(_, _) => true
        Space.Pow(_, _) => true
        _ => false
    end
end
