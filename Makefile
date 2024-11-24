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
	$(JL) -t 100 -e 'include("count_mis/count_mis2.jl"); main()'

count_lp:
	$(JL) -t 100 -e 'include("count_mis/count_lp.jl"); main()'

count_ip:
	$(JL) -t 100 -e 'include("count_mis/count_ip.jl"); main()'
