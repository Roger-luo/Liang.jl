module Prelude

using ..Data: Data, @data, pprint
using ..Reflection

export @data, pprint, Reflection, Data
for (name, methods) in Reflection.var"#INTERFACE_STUB#"
    @eval export $name
end

end # Prelude
