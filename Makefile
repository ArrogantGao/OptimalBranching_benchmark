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
	$(JL) -e 'include("Graphs/generate.jl"); gen(ErdosRenyiGraphSpec($(size), $(d)), $(nsample))'

ksg:
	$(JL) -e 'include("Graphs/generate.jl"); gen(KSGSpec($(m), $(n), $(filling)), $(nsample))'

sq:
	$(JL) -e 'include("Graphs/generate.jl"); gen(GridSpec($(m), $(n), $(filling)), $(nsample))'

count_all_opt_3rr_ip:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_all_3rr_ip()' 2>&1 | tee log/count_all_opt_3rr_ip.log

count_all_opt_3rr_lp:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_all_3rr_lp()' 2>&1 | tee log/count_all_opt_3rr_lp.log

count_all_opt_er_ip:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_all_er_ip()' 2>&1 | tee log/count_all_opt_er_ip.log

count_all_opt_er_lp:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_all_er_lp()' 2>&1 | tee log/count_all_opt_er_lp.log

count_all_opt_ksg:
	$(JL) -t $(threads) -e 'include("count_mis/count_optimal_branching.jl"); count_all_ksg()' 2>&1 | tee log/count_all_opt_ksg.log

count_all_mis2_3rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_mis2.jl"); count_all_3rr()' 2>&1 | tee log/count_all_mis2_3rr.log

count_all_mis2_er:
	$(JL) -t $(threads) -e 'include("count_mis/count_mis2.jl"); count_all_er()' 2>&1 | tee log/count_all_mis2_er.log

count_all_mis2_ksg:
	$(JL) -t $(threads) -e 'include("count_mis/count_mis2.jl"); count_all_ksg()' 2>&1 | tee log/count_all_mis2_ksg.log

count_all_xiao_3rr:
	$(JL) -t $(threads) -e 'include("count_mis/count_xiao.jl"); count_all_3rr()' 2>&1 | tee log/count_all_xiao_3rr.log

plot:
	$(JL) -e 'include("fig/compare_complexity_ip.jl"); include("fig/compare_ip_lp.jl");'