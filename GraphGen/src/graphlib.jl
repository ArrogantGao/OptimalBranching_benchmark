abstract type AbstractGraphSpec end

struct RegularGraphSpec <: AbstractGraphSpec
    size::Int
    degree::Int   # for d-regular graph
end
unique_string(g::RegularGraphSpec) = "Regular$(g.size)d$(g.degree)"
function render_graph(g::RegularGraphSpec, seed::Int)
    Random.seed!(seed)
    Graphs.random_regular_graph(g.size, g.degree)
end

struct KSGSpec <: AbstractGraphSpec
    m::Int
    n::Int
    filling::Float64
end
unique_string(g::KSGSpec) = "KSG$(g.m)x$(g.n)f$(g.filling)"
function render_graph(g::KSGSpec, seed::Int)
    Random.seed!(seed)
    GenericTensorNetworks.random_diagonal_coupled_graph(g.m, g.n, g.filling)
end

struct GridSpec <: AbstractGraphSpec
    m::Int
    n::Int
    filling::Float64
end
unique_string(g::GridSpec) = "Grid$(g.m)x$(g.n)f$(g.filling)"
function render_graph(g::GridSpec, seed::Int)
    Random.seed!(seed)
    GenericTensorNetworks.random_square_lattice_graph(g.m, g.n, g.filling)
end

struct ErdosRenyiGraphSpec <: AbstractGraphSpec
    size::Int
    mean_degree::Int
end
unique_string(g::ErdosRenyiGraphSpec) = "ErdosRenyi$(g.size)d$(g.mean_degree)"
function render_graph(g::ErdosRenyiGraphSpec, seed::Int)
    Random.seed!(seed)
    Graphs.erdos_renyi(g.size, g.mean_degree / (g.size - 1))
end
