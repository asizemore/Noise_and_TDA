# Creating graphs
# Loads in all graph models generates .jl files for them. For Matlab files, loads in the matrices and saves them to a standard format
# Run as "julia --color=yes code/create_graphs.jl config_DATE.json

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
const GRAPH_MODELS = config["graph_models"]
const HOMEDIR = config["HOMEDIR"]
save_dir = "$(HOMEDIR)/$(config["save_dir_graphs"])/$(NNODES)nodes"



println("Preparing to create graphs for $(length(GRAPH_MODELS)) models.")


### Write all graphs

# Run for each graph model
for (graph_model, model_info) in GRAPH_MODELS

    model_name = model_info["name"]

    if model_info["createFlag"] == "create"
    
        println("Constructing $(graph_model)...")

        # Prepare the arrays - need to save the final weighted array and all parameters
        weighted_graph_array = zeros(NNODES,NNODES,NREPS)
        weighted_graph_array_draft = zeros(NNODES,NNODES,NREPS)

        model_fn = getfield(Main, Symbol(model_info["fn"]))
        model_parameters = model_info["parameters"]
        betti_file_name = []

        # Create NREPS replicates
        for rep in 1:NREPS

                G_i = model_fn(NNODES, model_parameters...)

                # We require edge density > 0.9
                edge_density = check_density(G_i)
                while edge_density < 0.9
                    G_i = model_fn(NNODES, model_parameters...)
                    edge_density = check_density(G_i)
                end

                betti_file_name = "$(model_name)_$(NNODES)nodes_$(NREPS)reps"
                for parameter in model_parameters
                    betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
                end


            # Check to ensure we have unique edge weights
            if length(unique([G_i...])) < (binomial(NNODES,2)+1)
                println("Edge weights not unique")
                G_ii = makeEdgeWeightsUnique(G_i)

            else
                G_ii = deepcopy(G_i)
            end

            # Check density
            edge_density = check_density(G_i)
            if edge_density < 0.8
                printstyled("EDGE DENSITY $(edge_density)", color=:red)
            end

            # Store created graph G_i

            if length(unique([G_ii...])) < (binomial(NNODES,2)+1)
                printstyled("Edge uniqueness did not work", color=:red)
            end

            weighted_graph_array[:,:,rep] = G_ii
            weighted_graph_array_draft[:,:,rep] = G_i

        end # ends replicate runs

        println("Finished creating $(NREPS) $(model_name) graphs with parameters $(model_parameters)")


        # Run checks on the created graphs
        println("make some graph checks! TODO")



        # Save graphs
        save("$(save_dir)/$(betti_file_name)_$(DATE_STRING)_$(NAMETAG).jld",
            "weighted_graph_array", weighted_graph_array,
            "weighted_graph_array_draft", weighted_graph_array_draft,
            "parameters", model_parameters)

        printstyled("Saved graphs to $(save_dir)/$(betti_file_name)_$(DATE_STRING)_$(NAMETAG).jld \n \n", color=:cyan)




    elseif model_info["createFlag"] == "hold"

            println("Waiting to create $(model_name).")
            
    end

end # ends graph model run

printstyled("Finished creating all graph models.\n")
printstyled("Elapsed time = $(time() - script_start_time)\n", color = :yellow)






