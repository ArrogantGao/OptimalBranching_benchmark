using OptimalBranching, Graphs, GraphGen
using Base.Threads
using CSV, DataFrames
using Statistics

function geometric_mean(x)
    return exp(mean(log.(x)))
end

const basedir = dirname(dirname(@__DIR__))

function count_mis(cfg)
    @info "Counting MIS for " * GraphGen.unique_string(cfg)
    graphs = read_graphs(joinpath(basedir, "OptimalBranching_benchmark/Graphs", GraphGen.unique_string(cfg), "graphs.g6"))

    all_mis = zeros(Int, length(graphs))
    all_counts = zeros(Int, length(graphs))

    #init 
    @info "init"
    counting_xiao2013(smallgraph(:tutte))
    @info "init done"

    num_tasks = length(graphs)

    @sync for id in 1:num_tasks
        Threads.@spawn begin
            graph = graphs[id]
            count_2 = counting_xiao2013(graph)

            all_mis[id] = count_2.size
            all_counts[id] = count_2.count

            percent = sum(!iszero, all_counts) / num_tasks
            @info "xiao2013, nv = $(nv(graph)), id = $id, mis = $(count_2.size), count = $(count_2.count), percent = $percent"
        end
    end

    data_file_name = joinpath(basedir, "OptimalBranching_benchmark/data", "$(GraphGen.unique_string(cfg))_count_xiao2013.csv")
    header = ["id", "mis", "count"]
    CSV.write(data_file_name, DataFrame(), header=header)
    CSV.write(data_file_name, DataFrame(id = 1:length(graphs), mis = all_mis, count = all_counts), append = true)

    @info "mean_count = $(mean(all_counts)), geometric_mean_count = $(geometric_mean(all_counts))"
end

function count_all_3rr()
    for i in 60:20:220
        count_mis(RegularGraphSpec(i, 3))
    end
end