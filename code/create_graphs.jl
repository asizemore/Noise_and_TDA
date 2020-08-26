# Creating graphs
# Loads in all graph models generates .jl files for them. For Matlab files, loads in the matrices and saves them to a standard format

script_start_time = time()
println("\nimporting packages...")

using Pkg
using Statistics
using Plots
using LinearAlgebra
using Distances
using Eirene
using StatsBase
using Random
using Distributions
using JLD
using MAT

println("packages imported")

println("importing functions...")

include("graph_models.jl")
include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) \n \n", color = :yellow)


### Set parameters for all graphs - could be arguments for this script

# main parameters
const NREPS = 50
const NNODES = 70
const SAVE_DATA = 1    # Boolean to save data  
const DATE_STRING = "082520"

# for geometricConf
const P = 0.01
const SCALE_FACTOR = 100

# for RG and cosineGeometric
const DIMS = 3

# for discreteUniformConf
const A = 0
const B = 1000

# All the names of any graph model that will get run
const GRAPH_MODEL_NAMES = ["geometricConf",
    "IID" ,
    "RG",
    "discreteUniformConf",
    "cosineGeometric",
    "RL",
    "assoc",
    "disassort",
    "coreperiph",
    "DP"]

println("Preparing to create graphs for $(length(GRAPH_MODEL_NAMES)) models.")




### Write all graphs

# Run for each graph model
for graph_model_name in GRAPH_MODEL_NAMES
    
    println("Constructing $(graph_model_name)...")

    # Prepare the arrays - need to save the final weighted array and all parameters
    weighted_graph_array = zeros(NNODES,NNODES,NREPS)
    weighted_graph_array_draft = zeros(NNODES,NNODES,NREPS)
    betti_file_name = []
    parameters = []


    # Create NREPS replicates
    for rep in 1:NREPS


        if graph_model_name == "geometricConf"
            G_i = make_dev_Geometric_configuration_model(NNODES,P,SCALE_FACTOR)
            parameters = [NREPS, NNODES, P, SCALE_FACTOR]
            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end


        elseif graph_model_name == "IID"
            G_i = make_iid_weighted_graph(NNODES)
            parameters = [NREPS, NNODES]
            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end


        elseif graph_model_name == "RG"
            G_i = make_random_geometric(NNODES,DIMS)
            parameters = [NREPS, NNODES, DIMS]
            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end


        elseif graph_model_name == "discreteUniformConf"
            G_i = make_dev_DiscreteUniform_configuration_model(NNODES,A,B)
            parameters = [NREPS, NNODES, A, B]
            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end


        elseif graph_model_name == "cosineGeometric"
            G_i = make_cosine_geometric(NNODES,DIMS)
            parameters = [NREPS, NNODES, DIMS]
            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end


        elseif graph_model_name == "RL"
            G_i = make_ring_lattice_wei(NNODES)
            parameters = [NREPS, NNODES]
            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end


        elseif graph_model_name == "assoc"

            mat_dict = matread("./data/associative_WSBM_70_10_10_2_2_09_05.mat")
            parameters = mat_dict["param_array"]
            G_i = mat_dict["adj_array"][:,:,rep]
            G_i = G_i+transpose(G_i)

            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end

        elseif graph_model_name == "coreperiph"

            mat_dict = matread("./data/coreperiph_WSBM_70_10_10_2_2_09_05.mat")
            parameters = mat_dict["param_array"]
            G_i = mat_dict["adj_array"][:,:,rep]
            G_i = G_i+transpose(G_i)

            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end


        elseif graph_model_name == "disassort"
            # These wsbm come out asymmetric. We don't need to worry about averaging the weights, just add the transpose.
            mat_dict = matread("./data/disassortative_WSBM_70_10_10_2_2_09_05.mat")
            parameters = mat_dict["param_array"]
            G_i = mat_dict["adj_array"][:,:,rep]
            G_i = G_i+transpose(G_i)

            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end


        elseif graph_model_name == "DP"
            G_i = make_dot_product(NNODES,DIMS)
            parameters = [NREPS, NNODES, DIMS]
            betti_file_name = "$(graph_model_name)"

            for parameter in parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end

        end # ends if-elses

        # Check to ensure we have unique edge weights
        if length(unique([G_i...])) < (NNODES+1)
            println("Edge weights not unique")
            G_ii = makeEdgeWeightsUnique(G_i)

        else
            G_ii = deepcopy(G_i)
        end

        # Store created graph G_i
        weighted_graph_array[:,:,rep] = G_ii
        weighted_graph_array_draft[:,:,rep] = G_i

    end # ends replicate runs

    println("Finished creating $(NREPS) $(graph_model_name) graphs with parameters $(parameters)")


    # Run checks on the created graphs
    println("make some graph checks! TODO")

    ## if not all unique edge weights, add noise.


    # Save graphs
    save("./processed_data/graphs/$(NNODES)nodes/$(betti_file_name)_$(DATE_STRING)_graphs.jld",
        "weighted_graph_array", weighted_graph_array,
        "weighted_graph_array_draft", weighted_graph_array_draft,
        "parameters", parameters)

    printstyled("Saved graphs to ./processed_data/graphs/$(NNODES)nodes/$(betti_file_name)_$(DATE_STRING)_graphs.jld \n \n", color=:cyan)




end # ends graph model run

printstyled("Finished creating all graph models.\n")
printstyled("Elapsed time = $(time() - script_start_time)\n", color = :yellow)






