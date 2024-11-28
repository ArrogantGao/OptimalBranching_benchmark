using Graphs

"""
    tree_like_N3_neighborhood(g0::SimpleGraph)

This function generates the tree-like N3 neighborhood of g0.

# Arguments
- `g0::SimpleGraph`: A simple graph from which three layers of neighbors will grow.

# Returns
- `g::SimpleGraph`: A simple graph composed of the subgraph g0 and its tree-like N3 neighborhood.

"""
function tree_like_N3_neighborhood(g0::SimpleGraph)
    g = copy(g0)
    for layer in 1:3
        for v in vertices(g)
            for _ = 1:(3-degree(g, v))
                add_vertex!(g)
                add_edge!(g, v, nv(g))
            end
        end
    end
    return g
end