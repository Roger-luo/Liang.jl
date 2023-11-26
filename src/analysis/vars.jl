vars(node::E) where {E} = vars!(Dict{Symbol,E}(), node)

function vars!(scope::Dict{Symbol,Index.Type}, node::Index.Type)
    for each in children(node)
        @match each begin
            Index.Variable(name) => (scope[name] = each)
            Index.NSites(name) => (scope[name] = each)
            _ => vars!(scope, each)
        end
    end
    return scope
end
