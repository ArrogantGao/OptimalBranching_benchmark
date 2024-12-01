using OptimalBranching, GraphGen, Graphs
using CSV, DataFrames, DelimitedFiles
using Statistics

function geometric_mean(x)
    return exp(mean(log.(x)))
end

const basedir = dirname(dirname(@__DIR__))

function config_name(solver, reducer)
    name_solver = solver == IPSolver() ? "ip" : "lp"
    name_reducer = reducer == MISReducer() ? "mis" : "xiao"
    return "$(name_solver)_$(name_reducer)"
end

function count_mis(cfg, k, solver, reducer)
    @info "Counting MIS for " * GraphGen.unique_string(cfg)
    branching_strategy = BranchingStrategy(table_solver = TensorNetworkSolver(; prune_by_env=true), set_cover_solver=solver, selector=MinBoundarySelector(k), measure=D3Measure())
    @show branching_strategy, reducer

    cname = config_name(solver, reducer)

    graphs = read_graphs(joinpath(basedir, "OptimalBranching_benchmark/Graphs", GraphGen.unique_string(cfg), "graphs.g6"))

    data_file_name = joinpath(basedir, "OptimalBranching_benchmark/data", "$(GraphGen.unique_string(cfg))_count_$(cname).csv")
    @info "writing to $data_file_name"

    header = ["id", "mis", "count"]
    CSV.write(data_file_name, DataFrame(), header=header)
    
    # init the functions
    @info "inilializing"
    mis_branch_count(smallgraph(:tutte), branching_strategy = branching_strategy, reducer = reducer)
    @info "inilialization done"

    all_mis = zeros(Int, length(graphs))
    all_counts = zeros(Int, length(graphs))

    nthreads = Threads.nthreads()

    @sync for id in 1:length(graphs)
        Threads.@spawn begin
            graph = graphs[id]
            (mis, count) = mis_branch_count(graph, branching_strategy = branching_strategy, reducer = reducer)

            @info "$(cname), nv = $(nv(graph)), id = $id, mis = $mis, count = $count"

            all_mis[id] = mis
            all_counts[id] = count
        end
    end

    CSV.write(data_file_name, DataFrame(id = 1:length(graphs), mis = all_mis, count = all_counts), append = true)

    @info "mean_count = $(mean(all_counts)), geometric_mean_count = $(geometric_mean(all_counts))"
end