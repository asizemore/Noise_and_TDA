### Slice graphs at threshold and add noise

println("Running threshold_graphs.jl")


script_start_time = time()
println("\nimporting packages...")

using Pkg
using Statistics
using LinearAlgebra
using StatsBase
using Random
using Distributions
using JLD
using JSON


println("packages imported")

println("importing functions...")

include("graph_models.jl")
include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) \n \n", color = :yellow)


### Set parameters for all graphs

config = read_config("$(pwd())/configs/$(ARGS[1])")

# Parameters for all graphs
const NNODES = config["NNODES"]
const THRESHVEC = config["THRESHVEC"]
const DATE_STRING = config["DATE_STRING"]
const SAVEDATA = config["SAVEDATA"]    # Boolean to save data  
const SAVETAIL = config["SAVETAIL_threshold_graphs"]
const HOMEDIR = config["HOMEDIR"]
read_dir = "$(HOMEDIR)/$(config["read_dir_graphs"])/$(NNODES)nodes"
save_dir = "$(HOMEDIR)/$(config["save_dir_thresh"])/$(NNODES)nodes"


### Locate data
graph_files = filter(x->occursin("_graphs.jld",x), readdir(read_dir))
graph_files = filter(x -> occursin(DATE_STRING,x), graph_files)


#### OPTIONAL filtering
graph_files = filter(x -> occursin("Triangle9",x), graph_files)
##########

println("Located the following graph files:")
for graph_file in graph_files
    println(graph_file)
end


### Run through graphs and compute Betti curves 
nEdges = binomial(NNODES, 2)
for (i,graph_file) in enumerate(graph_files)

    println("\nBeginning $(graph_file)")

    # Load in eirene output
    graphs_dict = load("$(read_dir)/$(graph_file)")

    weighted_graph_array = graphs_dict["weighted_graph_array"]
    nReps = size(weighted_graph_array)[3]

    for threshold in THRESHVEC

        weighted_graph_array_noise = zeros(NNODES, NNODES, nReps)
        noise_only_array = zeros(NNODES, NNODES, nReps)
        threshold_edge_number = 0

        for rep in 1:nReps

            G_i = weighted_graph_array[:,:,rep]
            
            # Check edge density
            edge_density = check_density(G_i)
            if edge_density<0.9
                printstyled("EDGE DENSITY $(edge_density)", color=:red)
            end
            
            # Threshold the graph
            G_thresholded, threshold_edge_number = threshold_graph(G_i,threshold,NNODES)


            # Now all real values are positive, non-zero. Add 1 to distinguish real values from noise
            G_thresholded[G_thresholded.>0] .= G_thresholded[G_thresholded .>0 ] .+1


            # Since all the real values are >1, we can add noise in the range (0,1) to any edge still 0
            noisyGraph = make_iid_weighted_graph(NNODES)
            G_noise = deepcopy(G_thresholded)
            G_noise[G_noise .== 0] .= noisyGraph[G_noise .== 0]

            # Create the noise only graph by setting all real values (>1) to 0 so that only noise is left.
            G_noiseOnly = deepcopy(G_noise)
            G_noiseOnly[G_noiseOnly.>1] .= 0

            # Store

            weighted_graph_array_noise[:,:,rep] = G_noise
            noise_only_array[:,:,rep] = G_noiseOnly

        end # end loop over replicates

        # Save 
        save_name = replace(graph_file, ".jld" => "")
        save("$(save_dir)/$(save_name)_thresh$(replace(string(threshold), "." => ""))_edge$(threshold_edge_number).jld",
            "weighted_graph_array_noise", weighted_graph_array_noise,
            "noise_only_array", noise_only_array)

        println("Threshold $(threshold) complete.")

            
        end # end loop over thresholds
        
        
    println("Finished $(graph_file)")

end # end loop over graph models

printstyled("Completed thresholding all graphs.", color=:green)
printstyled("Elapsed time = $(time() - script_start_time) \n \n", color = :yellow)




