using Test
using Liang.Prelude

@testset "Liang.jl" begin
    @test 1 == 1
end # Liang.jl tests

H = sum(Lattice.square(index"i"), [index"i"] => Op.X[index"i"] * Op.X[index"i" + 1])
U_t = exp(-im * scalar"t" * H)
canonicalize(U_t)

@routine Scalar foo(x, y) = x + y + z

foo(x, y) + sin(x)

# input: foo(abs(θ), 1.0)
# output:
abs(θ) + 1.0 + z
