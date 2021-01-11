### Run thresholded graphs through persistent homology

println("Running run_ph_threshold.jl")

### Run persistent homology


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
using Dates
using JSON

println("packages imported")

println("importing functions...")

include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)
printstyled("Starting script evaluation at $(Dates.Time(Dates.now())) \n \n", color = :yellow)

### Set parameters
localARGS = @isdefined(loopARGS) ? loopARGS : ARGS
println(localARGS)

config = read_config("$(pwd())/configs/$(localARGS[1])")


### Read graph file from shell input
const graph_file =  split(localARGS[2],"/")[end]

# Parameters for all graphs
NNODES = config["NNODES"]
const SAVEDATA = config["SAVEDATA"]    # Boolean to save data  
const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
const SAVETAIL = config["SAVETAIL_ph_thresholds"]
DATE_STRING = config["DATE_STRING"]
HOMEDIR = config["HOMEDIR"]
read_dir = "$(HOMEDIR)/$(config["read_dir_thresh"])/$(NNODES)nodes"
save_dir = "$(HOMEDIR)/$(config["save_dir_results"])/$(NNODES)nodes"


### Locate graph to read
println("Located the following graph file:")
println(graph_file)



### Read in files and run PH
graph_model = split(graph_file, "_")[1]

nEdges = binomial(NNODES, 2)


printstyled("\nBeginning persistent homology loop\n\n", color = :pink)
# Loop over graph files and run persistent homology. Store barcodes.
# for (i,graph_file) in enumerate(graph_files)
if occursin(DATE_STRING,graph_file)

    println("Starting persistent homology for $(graph_model)\n")

    # Load in weighted_graph_array_noise (call it weighted_graph_array for ease later)
    graph_dict = load("$(read_dir)/$(graph_file)")
    weighted_graph_array = graph_dict["weighted_graph_array_noise"]

    # Ensure array is not all 0s
    if sum(weighted_graph_array)==0
        printstyled("ALL ENTRIES 0 IN GRAPH", color=:red)
    end

    # Find number of reps
    nReps = size(weighted_graph_array)[3]

    # Prepare arrays
    barcodeArray = Array{Array{Float64}}(undef,nReps,MAXDIM)

    for rep in 1:nReps

        # Extract replicate
        G_i = weighted_graph_array[:,:,rep]

        # G_i is a weighted graph. We need to order it
        edge_list_ranks = denserank([G_i...], rev = true)   # so highest edge weight gets assigned 1
        G_i_ord = reshape(edge_list_ranks,(NNODES,NNODES))
        G_i_ord[diagind(G_i_ord)] .= 0

        # size of mat check
        printstyled("Input matrix size is $(size(G_i_ord))\n", color=:orange)

        # Edge weights check
        tf_ew = unique([G_i...]) == collect(0:nEdges)
        if !tf_ew
            printstyled("Edge weights are misnumbered", color=:red)
        end
  


        # Run Eirene
        C = Eirene.eirene(G_i_ord,model = "vr", maxdim = MAXDIM, record = "none")
    
        # Store in barcodeArray
        for k in collect(1:MAXDIM)
            barcodeArray[rep, k] = barcode(C,dim=k)
        end

        if rep%20 == 0
            println("Run $(rep) completed.")
        end

        C = 0
    end


    printstyled("Completed computations for $(graph_model).\n", color = :green)

    # Save data
    if SAVEDATA==1
        saveName = replace(graph_file, ".jld" => "")
        saveName = replace(saveName, "_graphs" => "")
        save("$(save_dir)/$(saveName)_$(SAVETAIL).jld",
            "barcodeArray", barcodeArray)

        printstyled("Completed saving eirene outputs for $(graph_model).\n", color = :green)
        println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL).jld")
    end
    printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)


else
    println("Incorrect date - skipping file")

end