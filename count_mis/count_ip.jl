using OptimalBranching, GraphGen, Graphs
using CSV, DataFrames, DelimitedFiles

const basedir = dirname(dirname(@__DIR__))

function count_mis(cfg, k)
    @info "Counting MIS for " * GraphGen.unique_string(cfg)
    graphs = read_graphs(joinpath(basedir, "OptimalBranching_benchmark/Graphs", GraphGen.unique_string(cfg), "graphs.g6"))

    data_file_name = joinpath(basedir, "OptimalBranching_benchmark/data", "$(GraphGen.unique_string(cfg))_count_ip.csv")
    header = ["id", "mis", "count"]
    CSV.write(data_file_name, DataFrame(), header=header)

    branching_strategy = OptBranchingStrategy(TensorNetworkSolver(), IPSolver(), EnvFilter(), MinBoundarySelector(k), D3Measure())
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

    Threads.@threads for id in 1:length(graphs)
        graph = graphs[id]
        problem = MISProblem(graph)
        res = branch(problem, config)

        mis = res.mis_size
        count = res.mis_count

        @info "n = $(nv(graph)), id = $id, mis = $mis, count = $count"

        all_mis[id] = mis
        all_counts[id] = count
    end
    CSV.write(data_file_name, DataFrame(id = 1:length(graphs), mis = all_mis, count = all_counts), append = true)
end

# function main()
#     for i in 140:20:260
#         count_mis(RegularGraphSpec(i, 3), 2)
#     end
# end

# main()