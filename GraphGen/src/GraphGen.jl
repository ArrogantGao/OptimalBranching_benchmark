module GraphGen

using Graphs, GenericTensorNetworks, Random, GraphIO
export RegularGraphSpec, KSGSpec, GridSpec, ErdosRenyiGraphSpec, AbstractGraphSpec
export dump_graphs, read_graphs

include("graphlib.jl")
include("graphio.jl")

end
