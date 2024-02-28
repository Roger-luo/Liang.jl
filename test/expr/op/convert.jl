using Liang.Expression.Prelude
using Liang.Expression: mat
using Liang.Data.Prelude
using LuxurySparse: IMatrix, PermMatrix
using Test

@testset begin
    op_value = OpValue.Pauli(UInt8[0x00, 0x00])

    m = mat(op_value)

    op = convert(OpValue.Type, m)

    @test variant_name(op) == :Identity
    @test m isa IMatrix

    op_value = OpValue.Pauli(UInt8[0x00, 0x01])

    m = mat(op_value)

    op = convert(OpValue.Type, m)

    @test variant_name(op) == :Perm
    @test m isa PermMatrix
    @test m.perm == [2, 1, 4, 3]
    @test m.vals == Num.Type[1, 1, 1, 1]
end
