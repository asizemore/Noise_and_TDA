## Compute Betti bar and other values

script_start_time = time()
println("\nimporting packages...")

## Import packages

using Statistics
using Pkg
using LinearAlgebra
using StatsBase
using Random
using JLD
using Plots
using Distributions
using JSON
using MAT
Pkg.add("PyCall")
using PyCall
nx = pyimport("networkx")

include("helper_functions.jl")

println("packages imported")

println("importing functions...")

include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)



# Define parameters

# Read from config file
config_file = ARGS[1]
config = read_config("$(homedir())/configs/$(config_file)")

const NNODES = config["NNODES"]
const MAXDIM = config["MAXDIM"]
const NREPS = config["NREPS"]
const DATE_STRING = config["DATE_STRING"]
const SAVETAIL = config["SAVETAIL_netStats"]
const read_dir = "$(homedir())/$(config["read_dir_graphs"])/$(NNODES)nodes"
const save_dir = "$(homedir())/$(config["save_dir_results"])/$(NNODES)nodes"

# Locate graph files
graph_files = filter(x->occursin(DATE_STRING,x), readdir(read_dir))
println("Located the following graph files:")
for graph_file in graph_files
    println(graph_file)
end
model_names = [split(graph_file,"_")[1] for graph_file in graph_files]





## Run through graph metrics and save as mat for jason



names_ordered = []
sort!(graph_files)
    

for graph_file in graph_files
    
    graph_dict = load("$(read_dir)/$(graph_file)")
    


    # If the file is of threshold type, we want to compute values for the first half and second half as well
    if occursin("thresh", graph_file)

        weighted_graph_array = graph_dict["weighted_graph_array_noise"]
        noise_only_array = graph_dict["noise_only_array"]

        # Graph metrics
        clustering = zeros(1,NREPS)
        modularity = zeros(1,NREPS)
        avg_strength = zeros(1,NREPS)
        avg_shortest_path = zeros(1,NREPS)

        clustering_noiseOnly = zeros(1,NREPS)
        modularity_noiseOnly = zeros(1,NREPS)
        avg_strength_noiseOnly = zeros(1,NREPS)
        avg_shortest_path_noiseOnly = zeros(1,NREPS)

        clustering_prenoise = zeros(1,NREPS)
        modularity_prenoise = zeros(1,NREPS)
        avg_strength_prenoise = zeros(1,NREPS)
        avg_shortest_path_prenoise = zeros(1,NREPS)


        for rep in 1:NREPS

            g = nx.from_numpy_matrix(weighted_graph_array[:,:,rep], parallel_edges=false)

            clustering[1, rep] = nx.average_clustering(g, weight = "weight")
            modularity[1, rep] = nx.algorithms.community.modularity(g, nx.algorithms.community.label_propagation_communities(g))
            avg_strength[1, rep] = mean(triu_elements(weighted_graph_array[:,:,rep], 1))
            avg_shortest_path[1, rep] = nx.average_shortest_path_length(g, weight="weight")


            g_noiseOnly = nx.from_numpy_matrix(noise_only_array[:,:,rep], parallel_edges=false)
            clustering_noiseOnly[1, rep] = nx.average_clustering(g_noiseOnly, weight = "weight")
            modularity_noiseOnly[1, rep] = nx.algorithms.community.modularity(g_noiseOnly, nx.algorithms.community.label_propagation_communities(g_noiseOnly))
            avg_strength_noiseOnly[1, rep] = mean(triu_elements(noise_only_array[:,:,rep], 1))
            avg_shortest_path_noiseOnly[1, rep] = nx.is_connected(g_noiseOnly) ? nx.average_shortest_path_length(g_noiseOnly, weight="weight") : Inf


            # Calculate rho
            rho = split(split(graph_file, "thresh")[2],"_")[1]
            rho = replace(rho, "0" => "0.")
            rho = parse(Float64, rho)

            # Compute net stats on thresholded real graph.
            thresholded_graph, thresh_edgenumber = threshold_graph(weighted_graph_array[:,:,rep],rho,NNODES)

            g_prenoise = nx.from_numpy_matrix(thresholded_graph, parallel_edges=false)
            clustering_prenoise[1, rep] = nx.average_clustering(g_prenoise, weight = "weight")
            modularity_prenoise[1, rep] = nx.algorithms.community.modularity(g_prenoise, nx.algorithms.community.label_propagation_communities(g_prenoise))
            avg_strength_prenoise[1, rep] = mean(triu_elements(thresholded_graph, 1))
            avg_shortest_path_prenoise[1, rep] = nx.is_connected(g_prenoise) ? nx.average_shortest_path_length(g_prenoise, weight="weight") : Inf

        end
                
                

        # Save bettisArray
        saveName = replace(graph_file, ".jld"=> "")
        saveName = replace(saveName, "_graphs" => "")
        save("$(save_dir)/$(saveName)_$(SAVETAIL).jld",
                "clustering", clustering,
                "modularity", modularity,
                "avg_strength", avg_strength,
                "avg_shortest_path", avg_shortest_path)

        save("$(save_dir)/$(saveName)_$(SAVETAIL)_noiseOnly.jld",
                "clustering_noiseOnly", clustering_noiseOnly,
                "modularity_noiseOnly", modularity_noiseOnly,
                "avg_strength_noiseOnly", avg_strength_noiseOnly,
                "avg_shortest_path_noiseOnly", avg_shortest_path_noiseOnly)

        save("$(save_dir)/$(saveName)_$(SAVETAIL)_prenoise.jld",
                "clustering_prenoise", clustering_prenoise,
                "modularity_prenoise", modularity_prenoise,
                "avg_strength_prenoise", avg_strength_prenoise,
                "avg_shortest_path_prenoise", avg_shortest_path_prenoise)
        
        printstyled("Completed saving network statistics for $(saveName).\n", color = :green)
        println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL).jld")
        printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)



    else # If not a threhsold type - then counts as a regular, forward type

        weighted_graph_array = graph_dict["weighted_graph_array"]

        # Graph metrics
        nModels = length(graph_files)
        clustering = zeros(1,NREPS)
        modularity = zeros(1,NREPS)
        avg_strength = zeros(1,NREPS)
        avg_shortest_path = zeros(1,NREPS)


        for rep in 1:NREPS

            g = nx.from_numpy_matrix(weighted_graph_array[:,:,rep], parallel_edges=false)
            clustering[1, rep] = nx.average_clustering(g, weight = "weight")
            modularity[1, rep] = nx.algorithms.community.modularity(g, nx.algorithms.community.label_propagation_communities(g))
            avg_strength[1, rep] = mean(triu_elements(weighted_graph_array[:,:,rep], 1))
            avg_shortest_path[1, rep] = nx.average_shortest_path_length(g, weight="weight")

        end
                
                

        # Save bettisArray
        saveName = replace(graph_file, ".jld"=> "")
        saveName = replace(saveName, "_graphs" => "")
        save("$(save_dir)/$(saveName)_forward_$(SAVETAIL).jld",
                "clustering", clustering,
                "modularity", modularity,
                "avg_strength", avg_strength,
                "avg_shortest_path", avg_shortest_path)
        
        printstyled("Completed saving network statistics for $(saveName).\n", color = :green)
        println("Saved outputs to $(save_dir)/$(saveName)_forward_$(SAVETAIL).jld")
        printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)


        
    end


end
            
  


   