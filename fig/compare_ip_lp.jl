using CSV, DataFrames, CairoMakie, Statistics, LaTeXStrings, GraphGen, Graphs
using LsqFit

using OptimalBranching

const basedir = dirname(dirname(@__DIR__))
const data_dir = joinpath(basedir, "OptimalBranching_benchmark/data")
const graph_dir = joinpath(basedir, "OptimalBranching_benchmark/Graphs")

const measure = D3Measure()

function geometric_mean(x)
    return exp(mean(log.(x)))
end

ns_mis2_rr = [60:20:160...]

count_mis2_rr = Vector{Vector{Int}}()

for n in ns_mis2_rr
    cfg = GraphGen.RegularGraphSpec(n, 3)
    df_mis2 = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_mis2.csv"), DataFrame)
    push!(count_mis2_rr, df_mis2.count)
end

ns_rr = [60:20:200...]

count_ip_rr = Vector{Vector{Int}}()
count_lp_rr = Vector{Vector{Int}}()
measure_rr = Vector{Float64}()


for n in ns_rr
    cfg = GraphGen.RegularGraphSpec(n, 3)
    df_ip = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_ip_mis.csv"), DataFrame)
    df_lp = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_lp_mis.csv"), DataFrame)
    push!(count_ip_rr, df_ip.count)
    push!(count_lp_rr, df_lp.count)

    graphs = read_graphs(joinpath(graph_dir, GraphGen.unique_string(cfg), "graphs.g6"))
    measures = [OptimalBranching.OptimalBranchingMIS.OptimalBranchingCore.measure(MISProblem(g), measure) for g in graphs]
    push!(measure_rr, mean(measures))
end


ns_er = [60:20:200...]
ns_mis2_er = [60:20:160...]

count_ip_er = Vector{Vector{Int}}()
count_lp_er = Vector{Vector{Int}}()
count_mis2_er = Vector{Vector{Int}}()
measure_er = Vector{Float64}()

for n in ns_er
    cfg = GraphGen.ErdosRenyiGraphSpec(n, 0.03)
    df_ip = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_ip_mis.csv"), DataFrame)
    df_lp = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_lp_mis.csv"), DataFrame)
    push!(count_ip_er, df_ip.count)
    push!(count_lp_er, df_lp.count)
    graphs = read_graphs(joinpath(graph_dir, GraphGen.unique_string(cfg), "graphs.g6"))
    measures = [OptimalBranching.OptimalBranchingMIS.OptimalBranchingCore.measure(MISProblem(g), measure) for g in graphs]
    push!(measure_er, mean(measures))
end

for n in ns_mis2_er
    cfg = GraphGen.RegularGraphSpec(n, 3)
    df_mis2 = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_mis2.csv"), DataFrame)
    push!(count_mis2_er, df_mis2.count)
end

ms_ksg = [8:14...]
ns_ksg = Int.(ceil.([8:14...] .^2 .* 0.8))

count_ip_ksg = Vector{Vector{Int}}()
count_lp_ksg = Vector{Vector{Int}}()
count_mis2_ksg = Vector{Vector{Int}}()
measure_ksg = Vector{Float64}()

for m in ms_ksg
    cfg = GraphGen.KSGSpec(m, m, 0.8)
    df_ip = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_ip_mis.csv"), DataFrame)
    df_lp = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_lp_mis.csv"), DataFrame)
    push!(count_ip_ksg, df_ip.count)
    push!(count_lp_ksg, df_lp.count)
    df_mis2 = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_mis2.csv"), DataFrame)
    push!(count_mis2_ksg, df_mis2.count)
    graphs = read_graphs(joinpath(graph_dir, GraphGen.unique_string(cfg), "graphs.g6"))
    measures = [OptimalBranching.OptimalBranchingMIS.OptimalBranchingCore.measure(MISProblem(g), measure) for g in graphs]
    push!(measure_ksg, mean(measures))
end

@. model(x, p) = p[1] * x + p[2]

p0 = [1.0, 1.0]

n0 = 3

fit_rr_mis2 = curve_fit(model, ns_mis2_rr[n0:end], log10.(geometric_mean.(count_mis2_rr[n0:end])), p0)
fit_rr_ip = curve_fit(model, ns_rr[n0:end], log10.(geometric_mean.(count_ip_rr[n0:end])), p0)
fit_rr_lp = curve_fit(model, ns_rr[n0:end], log10.(geometric_mean.(count_lp_rr[n0:end])), p0)

fit_er_mis2 = curve_fit(model, ns_mis2_er[n0:end], log10.(geometric_mean.(count_mis2_er[n0:end])), p0)
fit_er_ip = curve_fit(model, measure_er[n0:end], log10.(geometric_mean.(count_ip_er[n0:end])), p0)
fit_er_lp = curve_fit(model, measure_er[n0:end], log10.(geometric_mean.(count_lp_er[n0:end])), p0)

fit_ksg_mis2 = curve_fit(model, measure_ksg[n0:end], log10.(geometric_mean.(count_mis2_ksg[n0:end])), p0)
fit_ksg_ip = curve_fit(model, measure_ksg[n0:end], log10.(geometric_mean.(count_ip_ksg[n0:end])), p0)
fit_ksg_lp = curve_fit(model, measure_ksg[n0:end], log10.(geometric_mean.(count_lp_ksg[n0:end])), p0)

@info "rr_mis2: $(10^fit_rr_mis2.param[1])"
@info "rr_ip: $(10^fit_rr_ip.param[1])"
@info "rr_lp: $(10^fit_rr_lp.param[1])"

@info "er_mis2: $(10^fit_er_mis2.param[1])"
@info "er_ip: $(10^fit_er_ip.param[1])"
@info "er_lp: $(10^fit_er_lp.param[1])"

@info "ksg_mis2: $(10^fit_ksg_mis2.param[1])"
@info "ksg_ip: $(10^fit_ksg_ip.param[1])"
@info "ksg_lp: $(10^fit_ksg_lp.param[1])"


fig = Figure(size = (1200, 400), fontsize = 23)
set_theme!(fonts = (; regular = "Montserrat", bold = "Montserrat Bold"))
ax1 = Axis(fig[1, 1], xlabel = "ρ(G)", ylabel = "Number of Branches", yscale = log10, title = "3-Regular Graphs")
ax2 = Axis(fig[1, 2], xlabel = "ρ(G)", yscale = log10, title = "Erdos-Renyi Graphs")
ax3 = Axis(fig[1, 3], xlabel = "ρ(G)", yscale = log10, title = "King's Graphs")
axs = [ax1, ax2, ax3]

counts = [[count_mis2_rr, count_ip_rr, count_lp_rr], [count_mis2_er, count_ip_er[3:end], count_lp_er[3:end]], [count_mis2_ksg, count_ip_ksg, count_lp_ksg]]
nums = [[ns_mis2_rr, ns_rr, ns_rr], [ns_mis2_er, measure_er[3:end], measure_er[3:end]], [measure_ksg for _ in 1:3]]
fits = [[fit_rr_mis2, fit_rr_ip, fit_rr_lp], [fit_er_mis2, fit_er_ip, fit_er_lp], [fit_ksg_mis2, fit_ksg_ip, fit_ksg_lp]]
labels = ["mis2", "ip_mis2", "lp_mis2"]
colors = [:blue, :green, :red]
markers = [:circle, :diamond, :utriangle]
ms = 12

for i in 1:3
    for j in 2:3
        scatter!(axs[i], nums[i][j], geometric_mean.(counts[i][j]), color = colors[j], label = labels[j], markersize = ms, marker = markers[j])
        lines!(axs[i], nums[i][j], 10 .^ (model(nums[i][j], fits[i][j].param)), color = colors[j], linewidth = 2, linestyle = :dash)
        # errorbars!(axs[i], nums[i][j], geometric_mean.(counts[i][j]), std.(counts[i][j]), color = colors[j], whiskerwidth = 10)
    end
end

xlims!(ax1, 40, 210)
xlims!(ax2, 80, 820)
xlims!(ax3, 140, 610)

axislegend(ax1, position = :lt, fontsize = 15, font = "Montserrat")
fig
save(joinpath(@__DIR__, "compare_ip_lp.pdf"), fig)
save(joinpath(@__DIR__, "compare_ip_lp.png"), fig)