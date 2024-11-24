using Test, GraphGen

@testset "write and load" begin
    filename = tempname()
    g = RegularGraphSpec(10, 3)
    dump_graphs(filename, g, 10)
    g2 = read_graphs(filename)
    expected = GraphGen.render_graph.(Ref(g), 1:10)
    @test all(g2 .== expected)
end