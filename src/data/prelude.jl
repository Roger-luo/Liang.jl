module Prelude

using ..Data: @data, pprint
using ..Reflection

export @data, pprint
for (name, methods) in Reflection.var"#INTERFACE_STUB#"
    @eval export $name
end

end # Prelude
