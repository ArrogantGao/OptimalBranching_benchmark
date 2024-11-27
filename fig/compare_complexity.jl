using CSV, DataFrames, CairoMakie, Statistics, LaTeXStrings, GraphGen
using LsqFit

const basedir = dirname(dirname(@__DIR__))

# Load data
const data_dir = joinpath(basedir, "OptimalBranching_benchmark/data")

function geometric_mean(x)
    return exp(mean(log.(x)))
end

ns_mis2 = [60:20:160...]
count_mis2 = Vector{Vector{Int}}()
for n in ns_mis2
    cfg = GraphGen.RegularGraphSpec(n, 3)
    df_mis2 = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_mis2.csv"), DataFrame)
    push!(count_mis2, df_mis2.count)
end

ns_setcover = [60:20:240...]
count_lp = Vector{Vector{Int}}()
count_ip = Vector{Vector{Int}}()
for n in ns_setcover
    cfg = GraphGen.RegularGraphSpec(n, 3) 
    df_ip = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_ip.csv"), DataFrame)
    df_lp = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_lp.csv"), DataFrame)
    push!(count_ip, df_ip.count)
    push!(count_lp, df_lp.count)
end

ns_setcover_xiao = [60:20:180...]
count_lp_xiao = Vector{Vector{Int}}()
count_ip_xiao = Vector{Vector{Int}}()
for n in ns_setcover_xiao
    cfg = GraphGen.RegularGraphSpec(n, 3)
    df_ip = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_ip_xiao.csv"), DataFrame)
    df_lp = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_lp_xiao.csv"), DataFrame)
    push!(count_ip_xiao, df_ip.count)
    push!(count_lp_xiao, df_lp.count)
end

ns_xiao = [60:20:240...]
count_xiao = Vector{Vector{Int}}()
for n in ns_xiao
    cfg = GraphGen.RegularGraphSpec(n, 3)
    df_xiao = CSV.read(joinpath(data_dir, "$(GraphGen.unique_string(cfg))_count_xiao2013.csv"), DataFrame)

    push!(count_xiao, df_xiao.count)
end

ns_plot = [50:20:290...]

n0 = 3

# @. model(x, p) = p[1]^x * p[2]
@. model(x, p) = p[1] * x + p[2]
p0 = [1.0, 1.0]
# fit_mis2 = curve_fit(model, ns_mis2[n0:end], log10.(mean.(count_mis2[n0:end])), p0)
# fit_lp = curve_fit(model, ns_setcover[n0:end], log10.(mean.(count_lp[n0:end])), p0)
# fit_ip = curve_fit(model, ns_setcover[n0:end], log10.(mean.(count_ip[n0:end])), p0)
# fit_xiao = curve_fit(model, ns_xiao[n0:end], log10.(mean.(count_xiao[n0:end])), p0)

fit_mis2 = curve_fit(model, ns_mis2[n0:end], log10.(geometric_mean.(count_mis2[n0:end])), p0)
fit_lp = curve_fit(model, ns_setcover[n0:end], log10.(geometric_mean.(count_lp[n0:end])), p0)
fit_ip = curve_fit(model, ns_setcover[n0:end], log10.(geometric_mean.(count_ip[n0:end])), p0)
fit_xiao = curve_fit(model, ns_xiao[n0:end], log10.(geometric_mean.(count_xiao[n0:end])), p0)
fit_lp_xiao = curve_fit(model, ns_setcover_xiao[n0:end], log10.(geometric_mean.(count_lp_xiao[n0:end])), p0)
fit_ip_xiao = curve_fit(model, ns_setcover_xiao[n0:end], log10.(geometric_mean.(count_ip_xiao[n0:end])), p0)

# fit_mis2 = curve_fit(model, ns_mis2, mean.(count_mis2), p0)
# fit_lp = curve_fit(model, ns_setcover, mean.(count_lp), p0)
# fit_ip = curve_fit(model, ns_setcover, mean.(count_ip), p0)
# fit_xiao = curve_fit(model, ns_xiao, mean.(count_xiao), p0)

ms = 12
marker_styles = [:circle, :diamond, :utriangle, :hexagon, :rect, :star5]
colors = [:blue, :green, :red, :purple, :orange, :brown]
locs_x = [150, 120, 220, 100, 120, 180]
locs_y = [100000, 1000, 5000, 10, 1000, 10]
labels = ["mis2", "opt_branching_lp", "opt_branching_ip", "xiao2013", "opt_branching_lp_xiao", "opt_branching_ip_xiao"]
nss = [ns_mis2, ns_setcover, ns_setcover, ns_xiao, ns_setcover_xiao, ns_setcover_xiao]
fit = [fit_mis2, fit_lp, fit_ip, fit_xiao, fit_lp_xiao, fit_ip_xiao]
begin
    fig = Figure(size = (800, 600), fontsize = 23)
    set_theme!(fonts = (; regular = "Montserrat", bold = "Montserrat Bold"))
    ax = Axis(fig[1, 1], xlabel = "Number of Vertices", ylabel = "Number of Branches", yscale = log10)
    for (i, count) in enumerate([count_mis2, count_lp, count_ip, count_xiao, count_lp_xiao, count_ip_xiao])
        scatter!(ax, nss[i], mean.(count), color = colors[i], label = labels[i], markersize = ms, marker = marker_styles[i])
        lines!(ax, ns_plot, 10 .^ (model(ns_plot, fit[i].param)), color = colors[i], linewidth = 2, linestyle = :dash)
        errorbars!(ax, nss[i], mean.(count), std.(count), color = colors[i], whiskerwidth = 10)
        # text!(locs_x[i], locs_y[i], text = L"O(%$(round(10^fit[i].param[1], digits = 4))^n)", color = colors[i], fontsize = 23)
    end

    axislegend(ax, position = :rb, fontsize = 15, font = "Montserrat")
end
xlims!(ax, 45, 295)
ylims!(ax, 1, 1e6)
fig

save(joinpath(@__DIR__, "branching_comparison.pdf"), fig)