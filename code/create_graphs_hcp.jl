# Creating graphs
# Loads in all hcp data

script_start_time = time()
println("\nimporting packages...")

using Pkg
using Statistics
using LinearAlgebra
println("loaded LinearAlgebra")
using Distances
using StatsBase
using Random
using Distributions
using JLD
using MAT
using JSON

println("packages imported")

println("importing functions...")

include("graph_models.jl")
include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) \n \n", color = :yellow)


### Set parameters for all graphs

config = read_config("$(pwd())/configs/$(ARGS[1])")

# main parameters
const NREPS = config["NREPS"]
const NNODES = config["NNODES"]
const DATE_STRING = config["DATE_STRING"]
const NAMETAG = config["NAMETAG_creategraphs"]
save_dir = "$(homedir())/$(config["save_dir_graphs"])/$(NNODES)nodes"



println("Preparing to create graphs for hcp models.")

graph_name = "dsi_matrices"
fullname = "$(homedir())/data/HCP/$(graph_name)"
mat_dict = matread("$(fullname).mat")
dsi_counts = mat_dict["ls234_count"]
nReps = size(dsi_counts)[3]
nNodes = size(dsi_counts)[1]

## Record number of nonzero edges
nnz_edges = []
for rep in collect(1:nReps)
    G = dsi_counts[:,:, rep]
    nnz_edges_rep = length(G[G.> 0])./2
    push!(nnz_edges,nnz_edges_rep)
end

## Run through and add noise to edges with weight 0

# Get the minimum
min_weight = unique(sort([dsi_counts...]))[2]

nNoises = 15

dsi_noisy = zeros(nNodes,nNodes,nReps*nNoises)

# Now all noise will be those edges with weight <1
for rep in collect(1:nReps)


    G_i = dsi_counts[:,:,rep]

    for noise in collect(1:nNoises)
        G_i_noisy = G_i .+ rand(Float64, (nNodes,nNodes))
        G_i_noisy[diagind(G_i_noisy)] .=0
        G_i_noisy = (G_i_noisy + transpose(G_i_noisy))./2
        dsi_noisy[:,:, (rep-1)*nNoises + noise] .= G_i_noisy
    end
end

## Save graphs
betti_file_name = "$(graph_name)"
save("$(save_dir)/$(betti_file_name)_$(DATE_STRING)_$(NAMETAG).jld",
        "weighted_graph_array", dsi_noisy,
        "weighted_graph_array_draft", dsi_counts,
        "nnz_edges", nnz_edges)

printstyled("Saved graphs to $(save_dir)/$(betti_file_name)_$(DATE_STRING)_$(NAMETAG).jld \n \n", color=:cyan)


