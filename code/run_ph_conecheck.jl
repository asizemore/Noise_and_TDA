### Run persistent homology


println("Running run_ph_conecheck.jl")

script_start_time = time()
println("\nimporting packages...")

using Pkg
using Statistics
using LinearAlgebra
using Distances
using Eirene
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
printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)







### Set parameters
localARGS = @isdefined(loopARGS) ? loopARGS : ARGS
println(localARGS)

config = read_config("$(pwd())/configs/$(localARGS[1])")

# Parameters for all graphs
NNODES = config["NNODES"]
const SAVEDATA = config["SAVEDATA"]    # Boolean to save data  
const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
const SAVETAIL = config["SAVETAIL_ph_conecheck"]
DATE_STRING = config["DATE_STRING"]
HOMEDIR = config["HOMEDIR"]
read_dir = "$(homedir())/$(config["read_dir_graphs"])/$(NNODES)nodes"
save_dir = "$(homedir())/$(config["save_dir_results"])/$(NNODES)nodes"

### Read in from looping shell script
const graph_file =  split(localARGS[2],"/")[end]


### Locate graphs to read
# graph_files = filter(x->occursin("_graphs.jld",x), readdir(read_dir))
# graph_files = filter(x -> occursin(DATE_STRING,x), graph_files)
println("Located the following graph file:")
# for graph_file in graph_files
    println(graph_file)
# end


### Read in files and run PH
const graph_model = split(graph_file, "_")[1]
println("Identified the graph model: $(graph_model)")

const nEdges = binomial(NNODES, 2)
# add dimension 0?

# printstyled("\nBeginning persistent homology\n\n", color = :pink)
# Loop over graph files and run persistent homology. Store barcodes.
# for (i,graph_file) in enumerate(graph_files)
if occursin(DATE_STRING,graph_file)



    # Load in weighted_graph_array

    const weighted_graph_array = load("$(read_dir)/$(graph_file)", "weighted_graph_array")

    # Ensure array is not all 0s
    if sum(weighted_graph_array)==0
        printstyled("ALL ENTRIES 0 IN GRAPH", color=:red)
    end

    # Find number of reps
    const nReps = size(weighted_graph_array)[3]

    for n = collect(1:10)

        println("Starting persistent homology for $(graph_model)\n subtracting $(n) nodes")

        ## Remove the n nodes with the highest strength
        weighted_graph_array_smaller = zeros(NNODES-n, NNODES-n, nReps)
        for r = collect(1:nReps)
            G_n = copy(weighted_graph_array[:,:,r])

            for j = collect(1:n)

                # Sort nodes by strength
                G_strength = dropdims(sum(G_n, dims=1), dims=1)
                sorted_nodes = sortperm(G_strength, rev=true)
                highest_deg = sorted_nodes[1]
                G_smaller = G_n[1:end .!= highest_deg, 1:end .!= highest_deg]

                # Run and save ph

                G_n = deepcopy(G_smaller)


            end

            weighted_graph_array_smaller[:,:,r] = G_n
        end

        barcodeArray = createAndFillBarcodeArray(nReps,MAXDIM, weighted_graph_array_smaller)


        printstyled("Completed computations for $(graph_model) level $(n).\n", color = :green)

        # Save data
        saveName = replace(graph_file, ".jld" => "")
        saveName = replace(saveName, "_graphs" => "")

        save("$(save_dir)/$(saveName)_$(SAVETAIL)$(n).jld", "barcodeArray", barcodeArray)


        printstyled("Completed saving eirene outputs for $(graph_model).\n", color = :green)
        println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL)$(n).jld")
        printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)
    end

else
    println("Incorrect date - skipping file")
end

# end









