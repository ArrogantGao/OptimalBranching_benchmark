using OptimalBranching, Graphs
include("neighborhood_generator.jl")

#Define the branching region R
vs = [1,2,3,4,5,6,7,8]
edges = [(1, 2), (1, 5), (2, 3), (2, 6), (3, 4), (4, 5), (5, 8), (6, 7), (7, 8)]
branching_region = SimpleGraph(Graphs.SimpleEdge.(edges)) 

#Generate the tree-like N3 neighborhood of R
graph = tree_like_N3_neighborhood(branching_region)

#Use default solver and measure
measure = D3Measure()
table_solver = TensorNetworkSolver()
set_cover_solver = IPSolver()
pruner = EnvFilter()

#Pruning irrelevant entries
ovs = OptimalBranchingMIS.open_vertices(graph, vs)
subg, vmap = induced_subgraph(graph, vs)
tbl = OptimalBranchingMIS.reduced_alpha_configs(table_solver, subg, Int[findfirst(==(v), vs) for v in ovs])
@info "truth_table after pruning irrelevant entries:"
@show tbl

#Enhanced pruning via incorporating N1(R)
problem = MISProblem(graph)
pruned_tbl = OptimalBranchingMIS.OptimalBranchingCore.prune(tbl, pruner, measure, problem, vs)
@info "truth_table after enhanced pruning via incorporating N1(R):"
@show pruned_tbl

#Generate the optimal branching rule 
@info "the optimal branching rule on R:"
viz_optimal_branching(pruned_tbl, vs, problem, measure, set_cover_solver, MISSize)


