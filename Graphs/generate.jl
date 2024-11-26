using GraphGen, DelimitedFiles, GraphGen.GenericTensorNetworks
using Random
Random.seed!(1234)

function gen(cfg, nsample::Int)
    dir = dirof(cfg)
    filename = joinpath(dir, "graphs.g6")
    dump_graphs(filename, cfg, nsample)
end

function dirof(cfg::AbstractGraphSpec)
    dir = joinpath(@__DIR__, GraphGen.unique_string(cfg))
    mkpath(dir)
end
