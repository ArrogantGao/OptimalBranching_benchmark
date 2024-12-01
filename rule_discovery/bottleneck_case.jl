using Graphs
include("utils.jl")

#Define the branching region R
vs = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]
edges = [(1, 2), (1, 3), (1, 4), (2, 5), (2, 6), (3, 7), (3, 8), (4, 9), (4, 10), (5, 11), (5, 12), (6, 13), (6, 14), (7, 15), (7, 16), (8, 17), (8, 18), (9, 19), (9, 20), (10, 21), (10, 22), (11, 14), (12, 13), (15, 18), (16, 17), (19, 22), (20, 21)]
branching_region = SimpleGraph(Graphs.SimpleEdge.(edges)) 

#Generate the tree-like N3 neighborhood of R
graph = tree_like_N3_neighborhood(branching_region)

solve_opt_rule(branching_region, graph, vs)