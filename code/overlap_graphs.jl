### Slice graphs at overlap and add noise

println("Running overlap_graphs.jl")


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
const AVEC = config["AVEC"]
const BVEC = config["BVEC"]
const DATE_STRING = config["DATE_STRING"]
const HOMEDIR = config["HOMEDIR"]
read_dir = "$(HOMEDIR)/$(config["read_dir_graphs"])/$(NNODES)nodes"
save_dir = "$(HOMEDIR)/$(config["save_dir_overlap"])/$(NNODES)nodes"


### Locate data
graph_files = filter(x->occursin("_graphs.jld",x), readdir(read_dir))
graph_files = filter(x -> occursin(DATE_STRING,x), graph_files)


#### OPTIONAL filtering
# graph_files = filter(x -> occursin("star",x), graph_files)
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

    for (num,a) in enumerate(AVEC)

        b = BVEC[num]

        weighted_graph_array_overlap = zeros(NNODES, NNODES, nReps)   # For storing final thresholded with noise matrices

        for rep in 1:nReps

            G_i = weighted_graph_array[:,:,rep]
            
            # Check edge density
            edge_density = check_density(G_i)
            if edge_density<0.9
                printstyled("EDGE DENSITY $(edge_density)", color=:red)
            end

            # Prepare G_overlap
            G_overlap = zeros(NNODES,NNODES)

            # Order by ranks -- Note now we will NOT perform this step in the run_ph_overlaps code.
            edge_list_ranks = denserank([G_i...], rev = true)   # so highest edge weight gets assigned 1
            G_i_ord = reshape(edge_list_ranks,(NNODES,NNODES))
            G_i_ord[diagind(G_i_ord)] .= 0

            # Begin overlapping noise procedure
            edge_number = 1
            while edge_number <= nEdges
                
                # Calculate current edge density
                density = edge_number/nEdges
                
                # Compute the probability of adding a random edge for this density. p<0 for density < a, p > 1 for density > b.
                p = compute_probability(density, a, b)
                
                # Decide if we will add a random edge or real edge. Rand bounded in (0,1) so in the end we have effectively a stepwise linear function.
                r = rand(1)[1]
                if r < p
                    
                    # Add edge at random
                    open_edges = Tuple.(findall(G_overlap .== 0))
                    open_edges = filter(x -> (x[1] != x[2]), open_edges)
                    new_edge = sample(open_edges)
                    
                    G_overlap[new_edge[1], new_edge[2]] = edge_number
                    G_overlap[new_edge[2], new_edge[1]] = edge_number
                    
                    
                else
                    
                    # Add edge from real graph
                    real_edges = findall(G_i_ord .== edge_number)[1]
                    
                    G_overlap[real_edges[1], real_edges[2]] = edge_number
                    G_overlap[real_edges[2], real_edges[1]] = edge_number
                    
                    
                    
                end

                # Increment
                edge_number = edge_number+1

            end   # end while edge_number < nEdges
            
            
            # Store

            weighted_graph_array_overlap[:,:,rep] = G_overlap


        end # end loop over replicates

        # Save ################
        save_name = replace(graph_file, ".jld" => "")
        save("$(save_dir)/$(save_name)_overlap_a$(replace(string(a), "." => ""))_b$(replace(string(b), "." => "")).jld",
            "weighted_graph_array", weighted_graph_array,
            "weighted_graph_array_overlap", weighted_graph_array_overlap)


        println("Interval [$(a), $(b)] complete.")

            
        end # end loop over thresholds
        
        
    println("Finished $(graph_file)")

end # end loop over graph models

printstyled("Completed thresholding all graphs.", color=:green)
printstyled("Elapsed time = $(time() - script_start_time) \n \n", color = :yellow)




