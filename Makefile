JL = julia --project

default: init update

init:
	git clone https://github.com/ArrogantGao/OptimalBranching.jl; \
	cd OptimalBranching.jl; \
	make init; \
	cd ..; \
	$(JL) -e 'using Pkg; Pkg.develop([PackageSpec(; path = "OptimalBranching.jl"), PackageSpec(; path="GraphGen")]); Pkg.instantiate(); Pkg.precompile();'

update:
	cd OptimalBranching.jl; \
	make update; \
	cd ..; \
	$(JL) -e 'using Pkg; Pkg.update(); Pkg.precompile();'

rr:
	$(JL) -e 'include("Graphs/generate.jl"); gen(RegularGraphSpec($(size), $(d)), $(nsample))' 

er:
	$(JL) -e 'include("Graphs/generate.jl"); gen(ErdosRenyiGraphSpec($(size), $(p)), $(nsample))'

ksg:
	$(JL) -e 'include("Graphs/generate.jl"); gen(KSGSpec($(m), $(n), $(filling)), $(nsample))'

sq:
	$(JL) -e 'include("Graphs/generate.jl"); gen(GridSpec($(m), $(n), $(filling)), $(nsample))'

count_mis2_rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_mis2.jl"); count_mis(RegularGraphSpec($(i), 3))' 2>&1 | tee log/count_mis2_$(i).log

count_lp_rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(RegularGraphSpec($(i), 3), 2, LPSolver(), MISReducer())' 2>&1 | tee log/count_lp_$(i).log

count_lp_xiao_rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(RegularGraphSpec($(i), 3), 2, LPSolver(), XiaoReducer())' 2>&1 | tee log/count_lp_xiao_$(i).log

count_ip_rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(RegularGraphSpec($(i), 3), 2, IPSolver(), MISReducer())' 2>&1 | tee log/count_ip_$(i).log

count_ip_xiao_rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(RegularGraphSpec($(i), 3), 2, IPSolver(), XiaoReducer())' 2>&1 | tee log/count_ip_xiao_$(i).log

count_xiao2013_rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_xiao.jl"); count_mis(RegularGraphSpec($(i), 3))' 2>&1 | tee log/count_xiao_$(i).log

count_mis2_er:
	$(JL) -t $(threads) -e 'include("count_mis/count_mis2.jl"); count_mis(ErdosRenyiGraphSpec($(i), $(p)))' 2>&1 | tee log/count_mis2_er_$(i).log

count_lp_er:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(ErdosRenyiGraphSpec($(i), $(p)), 2, LPSolver(), MISReducer())' 2>&1 | tee log/count_lp_er_$(i).log

count_ip_er:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(ErdosRenyiGraphSpec($(i), $(p)), 2, IPSolver(), MISReducer())' 2>&1 | tee log/count_ip_er_$(i).log

count_mis2_ksg:
	$(JL) -t $(threads) -e 'include("count_mis/count_mis2.jl"); count_mis(KSGSpec($(m), $(n), $(filling)))' 2>&1 | tee log/count_mis2_ksg_$(m)_$(n).log

count_lp_ksg:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(KSGSpec($(m), $(n), $(filling)), 2, LPSolver(), MISReducer())' 2>&1 | tee log/count_lp_ksg_$(m)_$(n).log

count_ip_ksg:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(KSGSpec($(m), $(n), $(filling)), 2, IPSolver(), MISReducer())' 2>&1 | tee log/count_ip_ksg_$(m)_$(n).log

count_mis2_sq:
	$(JL) -t $(threads) -e 'include("count_mis/count_mis2.jl"); count_mis(GridSpec($(m), $(n), $(filling)))' 2>&1 | tee log/count_mis2_sq_$(m)_$(n).log

count_lp_sq:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(GridSpec($(m), $(n), $(filling)), 2, LPSolver(), MISReducer())' 2>&1 | tee log/count_lp_sq_$(m)_$(n).log

count_ip_sq:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_mis(GridSpec($(m), $(n), $(filling)), 2, IPSolver(), MISReducer())' 2>&1 | tee log/count_ip_sq_$(m)_$(n).log

count_all_opt_3rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_all_3rr()' 2>&1 | tee log/count_all_opt_3rr.log

count_all_xiao_3rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_xiao.jl"); count_all_3rr()' 2>&1 | tee log/count_all_xiao_3rr.log

count_all_mis2_3rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_mis2.jl"); count_all_3rr()' 2>&1 | tee log/count_all_mis2_3rr.log

count_all_opt_er:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_all_er()' 2>&1 | tee log/count_all_opt_er.log

count_all_opt_ksg:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_all_ksg()' 2>&1 | tee log/count_all_opt_ksg.log

plot:
	$(JL) -e 'include("fig/compare_complexity_ip.jl"); include("fig/compare_ip_lp.jl");'

PH2_rule:
	$(JL) -e 'include("rule_discovery/PH2_rule.jl");'

domination_rule:
	$(JL) -e 'include("rule_discovery/domination_rule.jl");'

bottleneck_rule:
	$(JL) -e 'include("rule_discovery/bottleneck_case.jl");'