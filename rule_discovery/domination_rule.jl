using Graphs
include("utils.jl")

#Define the branching region R
vs = [1,2,3,4,5]
edges = [(1, 2), (2, 3), (1, 3), (2, 4), (3, 4), (2, 5), (4, 5)]
branching_region = SimpleGraph(Graphs.SimpleEdge.(edges)) 

graph = tree_like_N3_neighborhood(branching_region)

solve_opt_rule(branching_region, graph, vs)