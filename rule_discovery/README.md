# Rule Discovery


Here are three typical examples of `OptimalBranching.jl` applied for rule discovery. Specifically, you can obtain the optimal branching rule for a given region `R` through the workflow outlined below.

Firstly, because the branching rule needs to consider the reduction of environmental measure, you must first generate a neighborhood for R. Here, we take the tree-like N3 as an example, `graph` is composed of the subgraph g0 and its tree-like N3 neighborhood.
```julia
graph = tree_like_N3_neighborhood(R)
```

Next, we need to provide the effective entries in the reduced alpha tensor. Here `vs` and `ovs` represent the vertices and inner boundaries of R as a subgraph of `graph`. The data structure of `tbl` is `BranchingTable`, which represents the bitstring of the configuration in a boundary-grouped MISs.
```julia
ovs = OptimalBranchingMIS.open_vertices(graph, vs)
subg, _ = induced_subgraph(graph, vs)
tbl = OptimalBranchingMIS.reduced_alpha_configs(table_solver, subg, Int[findfirst(==(v), vs) for v in ovs])

```

Then, we generate the candidate clauses from the `tbl`, and solve the weighted set cover problem to find the optimal branching rule.
```julia
candidate_clauses = OptimalBranchingMIS.OptimalBranchingCore.candidate_clauses(tbl)

problem = MISProblem(graph)
size_reductions = [measure(problem, m) - measure(first(apply_branch(problem, candidate.clause, vs)), m) for candidate in candidate_clauses]
selection, gamma = OptimalBranchingMIS.OptimalBranchingCore.minimize_γ(length(tbl.table), candidate_clauses, size_reductions, set_cover_solver; γ0=2.0)
```

Finally, generate the DNF formula from the selected clauses and visualize it.
```julia
dnf = DNF(map(i->candidate_clauses[i].clause, selection))
viz_dnf(dnf, vs)
```

Run the code by
```bash
julia --project=. rule_discovery/bottleneck_case.jl
julia --project=. rule_discovery/domination_rule.jl
julia --project=. rule_discovery/PH2_rule.jl
```
Here we show the results of `PH2_rule.jl` as an example
```bash
$ jp rule_discovery/PH2_rule.jl       
[ Info: solving the branching table...
[ Info: the length of the truth_table after pruning irrelevant entries: 9
[ Info: generating candidate clauses...
[ Info: the length of the candidate clauses: 55
[ Info: generating the optimal branching rule via set cover...
[ Info: the minimized gamma: 1.0839059681358738
[ Info: the optimal branching rule on R:
¬7
¬1 ∧ 2 ∧ ¬3 ∧ ¬4 ∧ 5 ∧ ¬6 ∧ 7 ∧ ¬8
