using CSV, DataFrames, CairoMakie, Statistics, LaTeXStrings, GraphGen
using LsqFit

const basedir = dirname(dirname(@__DIR__))
const data_dir = joinpath(basedir, "OptimalBranching_benchmark/data")

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


for n in ns_rr
    cfg = GraphGen.RegularGraphSpec(n, 3)
    df_ip = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_ip.csv"), DataFrame)
    df_lp = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_lp.csv"), DataFrame)
    push!(count_ip_rr, df_ip.count)
    push!(count_lp_rr, df_lp.count)
end


ns_er = [60:20:200...]
ns_mis2_er = [60:20:160...]

count_ip_er = Vector{Vector{Int}}()
count_lp_er = Vector{Vector{Int}}()
count_mis2_er = Vector{Vector{Int}}()

for n in ns_er
    cfg = GraphGen.ErdosRenyiGraphSpec(n, 0.03)
    df_ip = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_ip.csv"), DataFrame)
    df_lp = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_lp.csv"), DataFrame)
    push!(count_ip_er, df_ip.count)
    push!(count_lp_er, df_lp.count)
end

for n in ns_mis2_er
    cfg = GraphGen.RegularGraphSpec(n, 3)
    df_mis2 = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_mis2.csv"), DataFrame)
    push!(count_mis2_er, df_mis2.count)
end

ms_ksg = [8:12...]
ns_ksg = Int.(ceil.([8:12...] .^2 .* 0.8))

count_ip_ksg = Vector{Vector{Int}}()
count_lp_ksg = Vector{Vector{Int}}()
count_mis2_ksg = Vector{Vector{Int}}()

for m in ms_ksg
    cfg = GraphGen.KSGSpec(m, m, 0.8)
    df_ip = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_ip.csv"), DataFrame)
    df_lp = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_lp.csv"), DataFrame)
    push!(count_ip_ksg, df_ip.count)
    push!(count_lp_ksg, df_lp.count)
    df_mis2 = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_mis2.csv"), DataFrame)
    push!(count_mis2_ksg, df_mis2.count)
end


fig = Figure(size = (1200, 400), fontsize = 23)
set_theme!(fonts = (; regular = "Montserrat", bold = "Montserrat Bold"))
ax1 = Axis(fig[1, 1], xlabel = "Number of Vertices", ylabel = "Number of Branches", yscale = log10, title = "3-Regular Graphs")
ax2 = Axis(fig[1, 2], xlabel = "Number of Vertices", ylabel = "Number of Branches", yscale = log10, title = "Erdos-Renyi Graphs")
ax3 = Axis(fig[1, 3], xlabel = "Number of Vertices", ylabel = "Number of Branches", yscale = log10, title = "King's Graphs")
axs = [ax1, ax2, ax3]

counts = [[count_mis2_rr, count_ip_rr, count_lp_rr], [count_mis2_er, count_ip_er, count_lp_er], [count_mis2_ksg, count_ip_ksg, count_lp_ksg]]
nums = [[ns_mis2_rr, ns_rr, ns_rr], [ns_mis2_er, ns_er, ns_er], [ns_ksg for _ in 1:3]]
labels = ["mis2", "Integer Programming", "Linear Programming"]
colors = [:blue, :green, :red]
markers = [:circle, :diamond, :utriangle]
ms = 12

for i in 1:3
    for j in 2:3
        scatter!(axs[i], nums[i][j], geometric_mean.(counts[i][j]), color = colors[j], label = labels[j], markersize = ms, marker = markers[j])
    end
end

axislegend(ax1, position = :rb, fontsize = 15, font = "Montserrat")
fig
save(joinpath(@__DIR__, "compare_ip_lp.pdf"), fig)
save(joinpath(@__DIR__, "compare_ip_lp.png"), fig)