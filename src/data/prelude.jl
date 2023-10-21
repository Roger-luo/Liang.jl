module Prelude

using ..Data: @data
using ..Reflection

export @data
for (name, methods) in Reflection.var"#INTERFACE_STUB#"
    @eval export $name
end

end # Prelude
