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
    
    println("Constructing $(graph_model)...")

    # Prepare the arrays - need to save the final weighted array and all parameters
    weighted_graph_array = zeros(NNODES,NNODES,NREPS)
    weighted_graph_array_draft = zeros(NNODES,NNODES,NREPS)
    model_name = model_info["name"]
    model_fn = getfield(Main, Symbol(model_info["fn"]))
    model_parameters = model_info["parameters"]
    betti_file_name = []

    # Create NREPS replicates
    for rep in 1:NREPS

        if model_info["flag"] == "create"

            G_i = model_fn(NNODES, model_parameters...)
            betti_file_name = "$(model_name)_$(NNODES)nodes_$(NREPS)reps"
            for parameter in model_parameters
                betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
            end

        elseif model_info["flag"] == "load"

            G_i = model_fn(NNODES, rep, model_parameters...)
            betti_file_name = "$(model_name)_$(NNODES)nodes_$(NREPS)reps_$(model_parameters[2])"
            
        end
        


        # if graph_model_name == "geometricConf"
        #     G_i = make_dev_Geometric_configuration_model(NNODES,P,SCALE_FACTOR)
        #     parameters = [NREPS, NNODES, P, SCALE_FACTOR]
        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end


        # elseif graph_model_name == "IID"
        #     G_i = make_iid_weighted_graph(NNODES)
        #     parameters = [NREPS, NNODES]
        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end


        # elseif graph_model_name == "RG"
        #     G_i = make_random_geometric(NNODES,DIMS)
        #     parameters = [NREPS, NNODES, DIMS]
        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end


        # elseif graph_model_name == "discreteUniformConf"
        #     G_i = make_dev_DiscreteUniform_configuration_model(NNODES,A,B)
        #     parameters = [NREPS, NNODES, A, B]
        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end


        # elseif graph_model_name == "cosineGeometric"
        #     G_i = make_cosine_geometric(NNODES,DIMS)
        #     parameters = [NREPS, NNODES, DIMS]
        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end


        # elseif graph_model_name == "RL"
        #     G_i = make_ring_lattice_wei(NNODES)
        #     parameters = [NREPS, NNODES]
        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end


        # elseif graph_model_name == "assoc"

        #     mat_dict = matread("./data/associative_WSBM_70_10_10_2_2_09_05.mat")
        #     parameters = mat_dict["param_array"]
        #     G_i = mat_dict["adj_array"][:,:,rep]
        #     G_i = G_i+transpose(G_i)

        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end

        # elseif graph_model_name == "coreperiph"

        #     mat_dict = matread("./data/coreperiph_WSBM_70_10_10_2_2_09_05.mat")
        #     parameters = mat_dict["param_array"]
        #     G_i = mat_dict["adj_array"][:,:,rep]
        #     G_i = G_i+transpose(G_i)

        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end


        # elseif graph_model_name == "disassort"
        #     # These wsbm come out asymmetric. We don't need to worry about averaging the weights, just add the transpose.
        #     mat_dict = matread("./data/disassortative_WSBM_70_10_10_2_2_09_05.mat")
        #     parameters = mat_dict["param_array"]
        #     G_i = mat_dict["adj_array"][:,:,rep]
        #     G_i = G_i+transpose(G_i)

        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end


        # elseif graph_model_name == "DP"
        #     G_i = make_dot_product(NNODES,DIMS)
        #     parameters = [NREPS, NNODES, DIMS]
        #     betti_file_name = "$(graph_model_name)"

        #     for parameter in parameters
        #         betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        #     end

        # end # ends if-elses


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




end # ends graph model run

printstyled("Finished creating all graph models.\n")
printstyled("Elapsed time = $(time() - script_start_time)\n", color = :yellow)






