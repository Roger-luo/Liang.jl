module Python

using Liang.Match: @match
using Liang.Data: @data,
    is_data_type, 
    data_type_name, 
    variant_fieldnames, 
    variant_fieldtypes, 
    variant_name,
    variants,
    is_singleton
    

include("scan.jl")
include("emit.jl")

end # Python