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

    data_file_name = joinpath(basedir, "OptimalBranching_benchmark/data", "$(GraphGen.unique_string(cfg))_count_xiao2013.csv")
    header = ["id", "mis", "count"]
    CSV.write(data_file_name, DataFrame(), header=header)

    all_mis = zeros(Int, length(graphs))
    all_counts = zeros(Int, length(graphs))

    #init 
    @info "init"
    counting_xiao2013(smallgraph(:tutte))
    @info "init done"

    nthreads = Threads.nthreads()
    n = length(graphs) ÷ nthreads
    for i in 1:n
        Threads.@threads for id in (i-1)*nthreads + 1:min(i*nthreads, length(graphs))
            graph = graphs[id]
            count_2 = counting_xiao2013(graph)

            all_mis[id] = count_2.mis_size
            all_counts[id] = count_2.mis_count
            @info "xiao2013, nv = $(nv(graph)), id = $id, mis = $(count_2.mis_size), count = $(count_2.mis_count)"
        end
        CSV.write(data_file_name, DataFrame(id = (i-1)*nthreads + 1:min(i*nthreads, length(graphs)), mis = all_mis[(i-1)*nthreads + 1:min(i*nthreads, length(graphs))], count = all_counts[(i-1)*nthreads + 1:min(i*nthreads, length(graphs))]), append = true)
    end

    @info "mean_count = $(mean(all_counts)), geometric_mean_count = $(geometric_mean(all_counts))"
end