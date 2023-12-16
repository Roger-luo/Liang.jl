vars(node::E) where {E} = vars!(Dict{Variable.Type,E}(), node)

function vars!(scope::Dict{Variable.Type,Index.Type}, node::Index.Type)
    for each in children(node)
        @match each begin
            Index.Variable(x) => (scope[x] = each)
            Index.NSites(x) => (scope[x] = each)
            _ => vars!(scope, each)
        end
    end
    return scope
end

function vars!(scope::Dict{Variable.Type,Scalar.Type}, node::Scalar.Type)
    for each in children(node)
        @match each begin
            Scalar.Variable(x) => (scope[x] = each)
            Scalar.Subscript(ref) => (scope[ref] = each)
            _ => vars!(scope, each)
        end
    end
    return scope
end
