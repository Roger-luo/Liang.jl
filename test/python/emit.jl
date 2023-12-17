using Test


@testset "emit_python_type" begin
    for type in [Float64, Float32, Float16]
        @test emit_python_type(type) == "Decimal"
    end

    for type in [Int128, Int64, Int32, Int16, Int8]
        @test emit_python_type(type) == "int"
    end

    for type in [ComplexF64, ComplexF32, ComplexF16]
        @test emit_python_type(type) == "complex"
    end

    @test emit_python_type(Bool) == "bool"
    @test emit_python_type(Symbol) == "str"
    @test emit_python_type(String) == "str"
    @test emit_python_type(Nothing) == "None"
    @test emit_python_type(Vector{Float32}) == "List[Decimal]"
    @test emit_python_type(Set{Float32}) == "FrozenSet[Decimal]"
    @test emit_python_type(Tuple{Float32, Int32}) == "Tuple[Decimal, int]"
    @test emit_python_type(Dict{Float32, Int32}) == "Dict[Decimal, int]"
    @test emit_python_type(Union{Float32, Int32}) == "Union[Decimal, int]"
    @test emit_python_type(Any) == PythonCodeGenError.PythonTypeError("Unsupported type: Any")

end
