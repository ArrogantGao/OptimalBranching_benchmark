using GraphGen
using Test


@testset "graphlib" begin
    include("graphlib.jl")
end

@testset "graphio" begin
    include("graphio.jl")
end
