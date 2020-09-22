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

# So all edges need to be below min_weight (=308.0). We'll just have them be between (0,1).
# Add noise to the edges with edge wieght 0
noise_mat = rand(size(dsi_counts))
dsi_noisy = dsi_counts.+noise_mat

# Now all noise will be those edges with weight <1
for rep in collect(1:nReps)
    G_i = dsi_noisy[:,:,rep]
    G_i[diagind(G_i)] .=0
    dsi_noisy[:,:, rep] .= G_i
end

## Save graphs
betti_file_name = "$(graph_name)"
save("$(save_dir)/$(betti_file_name)_$(DATE_STRING)_$(NAMETAG).jld",
        "weighted_graph_array", dsi_noisy,
        "weighted_graph_array_draft", dsi_counts,
        "nnz_edges", nnz_edges)

printstyled("Saved graphs to $(save_dir)/$(betti_file_name)_$(DATE_STRING)_$(NAMETAG).jld \n \n", color=:cyan)


