using Graphs, OptimalBranching
using OptimalBranching.OptimalBranchingMIS.OptimalBranchingCore, OptimalBranching.OptimalBranchingMIS.OptimalBranchingCore.BitBasis

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

function solve_opt_rule(branching_region, graph, vs)
    #Use default solver and measure
    m = D3Measure()
    table_solver = TensorNetworkSolver(; prune_by_env=true)
    set_cover_solver = IPSolver()

    #Pruning irrelevant entries
    ovs = OptimalBranchingMIS.open_vertices(graph, vs)
    subg, vmap = induced_subgraph(graph, vs)
    @info "solving the branching table..."
    tbl = OptimalBranchingMIS.reduced_alpha_configs(table_solver, subg, Int[findfirst(==(v), vs) for v in ovs])
    @info "the length of the truth_table after pruning irrelevant entries: $(length(tbl.table))"

    @info "generating candidate clauses..."
    candidate_clauses = OptimalBranchingMIS.OptimalBranchingCore.candidate_clauses(tbl)
    @info "the length of the candidate clauses: $(length(candidate_clauses))"

    @info "generating the optimal branching rule via set cover..."
    problem = MISProblem(graph)
    size_reductions = [measure(problem, m) - measure(first(apply_branch(problem, candidate.clause, vs)), m) for candidate in candidate_clauses]
    selection, gamma = OptimalBranchingMIS.OptimalBranchingCore.minimize_γ(length(tbl.table), candidate_clauses, size_reductions, set_cover_solver; γ0=2.0)
    @info "the minimized gamma: $(gamma)"

    @info "the optimal branching rule on R:"
    dnf = DNF(map(i->candidate_clauses[i].clause, selection))
    viz_dnf(dnf, vs)
end

function viz_dnf(dnf::DNF{INT}, variables::Vector{T}) where {T, INT}
    for c in dnf.clauses
        println(join([iszero(readbit(c.val, i)) ? "¬$(variables[i])" : "$(variables[i])" for i = 1:bsizeof(INT) if readbit(c.mask, i) == 1], " ∧ "))
    end
end