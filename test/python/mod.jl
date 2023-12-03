using Liang.Python: emit_python_type, PythonCodeGenError, emit_data_type_module
using Test
using Liang.Data: @data, is_data_type

@data TestDataType begin
    A
    B(Float32)
end


is_data_type(TestDataType)
