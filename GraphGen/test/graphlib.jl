using Test, GraphGen, Graphs
using GraphGen: unique_string, render_graph

@testset "RegularGraphSpec" begin
    g = RegularGraphSpec(10, 3)
    @test unique_string(g) == "Regular10d3"
    @test nv(render_graph(g, 1)) == 10
end


@testset "KSGSpec" begin
    g = KSGSpec(10, 10, 0.5)
    @test unique_string(g) == "KSG10x10f0.5"
    @test nv(render_graph(g, 1)) == 50
end


@testset "GridSpec" begin
    g = GridSpec(10, 10, 0.5)
    @test unique_string(g) == "Grid10x10f0.5"
    @test nv(render_graph(g, 1)) == 50
end

@testset "ErdosRenyiGraphSpec" begin
    g = ErdosRenyiGraphSpec(10, 0.5)
    @test unique_string(g) == "ErdosRenyi10p0.5"
    @test nv(render_graph(g, 1)) == 10
end