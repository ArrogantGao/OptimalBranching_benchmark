using Graphs
include("utils.jl")

#Define the branching region R
vs = [1,2,3,4,5,6,7,8]
edges = [(1, 2), (1, 5), (2, 3), (2, 6), (3, 4), (4, 5), (5, 8), (6, 7), (7, 8)]
branching_region = SimpleGraph(Graphs.SimpleEdge.(edges)) 

#Generate the tree-like N3 neighborhood of R
graph = tree_like_N3_neighborhood(branching_region)

solve_opt_rule(branching_region, graph, vs)