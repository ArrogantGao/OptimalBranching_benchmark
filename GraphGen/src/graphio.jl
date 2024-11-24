function dump_graphs(filename::String, spec::AbstractGraphSpec, num_graphs::Int)
    open(filename, "w") do io
        for seed in 1:num_graphs
            g = render_graph(spec, seed)
            GraphIO.Graph6.savegraph6(io, g)
        end
    end
end

function read_graphs(filename::String)
    res = open(filename, "r") do f
        GraphIO.Graph6.loadgraph6_mult(f)
    end
    [res["graph$i"] for i in 1:length(res)]
end