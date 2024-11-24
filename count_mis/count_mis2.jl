using OptimalBranching, Graphs, GraphGen
using Base.Threads
using CSV, DataFrames

const basedir = dirname(dirname(@__DIR__))

function count_mis(cfg)
    @info "Counting MIS for " * GraphGen.unique_string(cfg)
    graphs = read_graphs(joinpath(basedir, "OptimalBranching_benchmark/Graphs", GraphGen.unique_string(cfg), "graphs.g6"))

    data_file_name = joinpath(basedir, "OptimalBranching_benchmark/data", "$(GraphGen.unique_string(cfg))_count_mis2.csv")
    header = ["id", "mis", "count"]
    CSV.write(data_file_name, DataFrame(), header=header)

    all_mis = zeros(Int, length(graphs))
    all_counts = zeros(Int, length(graphs))

    #init 
    @info "init"
    counting_mis2(smallgraph(:tutte))
    @info "init done"

    Threads.@threads for id in 1:length(graphs)

        graph = graphs[id]
        count_2 = counting_mis2(graph)

        all_mis[id] = count_2.mis_size
        all_counts[id] = count_2.mis_count
        @show id, count_2
    end

    CSV.write(data_file_name, DataFrame(id = 1:length(graphs), mis = all_mis, count = all_counts), append = true)
end

function main()
    for i in 60:20:160
        count_mis(RegularGraphSpec(i, 3))
    end
end

main()