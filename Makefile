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

count_mis2:
	$(JL) -t 100 -e 'include("count_mis/count_mis2.jl"); count_mis(RegularGraphSpec($(i), 3))' 2>&1 | tee log/count_mis2_$(i).log

count_lp_n:
	$(JL) -t 100 -e 'include("count_mis/count_lp.jl"); count_mis(RegularGraphSpec($(i), 3), 2)' 2>&1 | tee log/count_lp_$(i).log

count_lp_xiao_n:
	$(JL) -t 100 -e 'include("count_mis/count_lp_xiao.jl"); count_mis(RegularGraphSpec($(i), 3), 2)' 2>&1 | tee log/count_lp_xiao_$(i).log

count_ip_n:
	$(JL) -t 100 -e 'include("count_mis/count_ip.jl"); count_mis(RegularGraphSpec($(i), 3), 2)' 2>&1 | tee log/count_ip_$(i).log

count_ip_xiao_n:
	$(JL) -t 100 -e 'include("count_mis/count_ip_xiao.jl"); count_mis(RegularGraphSpec($(i), 3), 2)' 2>&1 | tee log/count_ip_xiao_$(i).log

count_xiao2013_n:
	$(JL) -t 100 -e 'include("count_mis/count_xiao.jl"); count_mis(RegularGraphSpec($(i), 3))' 2>&1 | tee log/count_xiao_$(i).log