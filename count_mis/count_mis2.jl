using OptimalBranching, Graphs, GraphGen
using Base.Threads
using CSV, DataFrames
using Statistics

const basedir = dirname(dirname(@__DIR__))

function geometric_mean(x)
    return exp(mean(log.(x)))
end

function count_mis(cfg)
    @info "Counting MIS for " * GraphGen.unique_string(cfg)
    graphs = read_graphs(joinpath(basedir, "OptimalBranching_benchmark/Graphs", GraphGen.unique_string(cfg), "graphs.g6"))

    all_mis = zeros(Int, length(graphs))
    all_counts = zeros(Int, length(graphs))

    #init 
    @info "init"
    counting_mis2(smallgraph(:tutte))
    @info "init done"

    num_tasks = length(graphs)

    Threads.@sync for id in 1:num_tasks
        Threads.@spawn begin
            graph = graphs[id]
            count_2 = counting_mis2(graph)

            all_mis[id] = count_2.size
            all_counts[id] = count_2.count

            percent = sum(!iszero, all_counts) / num_tasks

            @info "mis2, nv = $(nv(graph)), id = $id, mis = $(count_2.size), count = $(count_2.count), percent = $percent"
        end
    end

    @info "all done"

    data_file_name = joinpath(basedir, "OptimalBranching_benchmark/data", "$(GraphGen.unique_string(cfg))_count_mis2.csv")
    header = ["id", "mis", "count"]
    CSV.write(data_file_name, DataFrame(), header=header)
    CSV.write(data_file_name, DataFrame(id = 1:length(graphs), mis = all_mis, count = all_counts), append = true)

    @info "mean_count = $(mean(all_counts)), geometric_mean_count = $(geometric_mean(all_counts))"
end

function count_all_3rr()
    for i in 60:20:160
        count_mis(RegularGraphSpec(i, 3))
    end
end

function count_all_er()
    for i in 100:100:800
        count_mis(ErdosRenyiGraphSpec(i, 3))
    end
end

function count_all_ksg()
    for i in 8:1:15
        count_mis(KSGSpec(i, i, 0.8))
    end
end