using OptimalBranching, GraphGen, Graphs
using CSV, DataFrames, DelimitedFiles
using Statistics

const basedir = dirname(dirname(@__DIR__))

function geometric_mean(x)
    return exp(mean(log.(x)))
end

function count_mis(cfg, k)
    @info "Counting MIS for " * GraphGen.unique_string(cfg)
    graphs = read_graphs(joinpath(basedir, "OptimalBranching_benchmark/Graphs", GraphGen.unique_string(cfg), "graphs.g6"))

    data_file_name = joinpath(basedir, "OptimalBranching_benchmark/data", "$(GraphGen.unique_string(cfg))_count_lp.csv")
    header = ["id", "mis", "count"]
    CSV.write(data_file_name, DataFrame(), header=header)

    branching_strategy = OptBranchingStrategy(TensorNetworkSolver(), LPSolver(), EnvFilter(), MinBoundarySelector(2), D3Measure())
    config = SolverConfig(MISReducer(), branching_strategy, MISCount)

    @show config

    # init the functions
    @info "inilializing"
    branch(MISProblem(smallgraph(:tutte)), config)
    @info "inilialization done"

    @info "warming up"
    res = branch(MISProblem(graphs[1]), config)
    @info "warming up done"

    all_mis = zeros(Int, length(graphs))
    all_counts = zeros(Int, length(graphs))

    nthreads = Threads.nthreads()
    n = length(graphs) ÷ nthreads
    for i in 1:n
        Threads.@threads for id in (i-1)*nthreads + 1:min(i*nthreads, length(graphs))
            graph = graphs[id]
            problem = MISProblem(graph)
            res = branch(problem, config)

            mis = res.mis_size
            count = res.mis_count

            @info "lp, nv = $(nv(graph)), id = $id, mis = $mis, count = $count"

            all_mis[id] = mis
            all_counts[id] = count
        end
        CSV.write(data_file_name, DataFrame(id = (i-1)*nthreads + 1:min(i*nthreads, length(graphs)), mis = all_mis[(i-1)*nthreads + 1:min(i*nthreads, length(graphs))], count = all_counts[(i-1)*nthreads + 1:min(i*nthreads, length(graphs))]), append = true)
    end
    @info "mean_count = $(mean(all_counts)), geometric_mean_count = $(geometric_mean(all_counts))"
end