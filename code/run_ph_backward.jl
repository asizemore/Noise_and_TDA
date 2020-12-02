### Run persistent homology


println("Running run_ph_backward.jl")


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

include("graph_models.jl")
include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)
printstyled("Starting script evaluation at $(Dates.Time(Dates.now())) \n \n", color = :yellow)

### Set parameters
localARGS = @isdefined(loopARGS) ? loopARGS : ARGS
println(localARGS)

config = read_config("$(pwd())/configs/$(localARGS[1])")

# Parameters for all graphs
NNODES = config["NNODES"]
const SAVEDATA = config["SAVEDATA"]    # Boolean to save data  
const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
const SAVETAIL = config["SAVETAIL_ph_backward"]
DATE_STRING = config["DATE_STRING"]
HOMEDIR = config["HOMEDIR"]
read_dir = "$(HOMEDIR)/$(config["read_dir_graphs"])/$(NNODES)nodes"
save_dir = "$(HOMEDIR)/$(config["save_dir_results"])/$(NNODES)nodes"


### Read in from looping shell script
graph_file =  split(localARGS[2],"/")[end]

### Locate graphs to read
# graph_files = filter(x->occursin("_graphs.jld",x), readdir(read_dir))
# graph_files = filter(x -> occursin(DATE_STRING,x), graph_files)

println("Located the following graph file:")
# for graph_file in graph_files
    println(graph_file)
# end


### Read in files and run PH
const graph_model = split(graph_file, "_")[1]

const nEdges = binomial(NNODES, 2)


# printstyled("\nBeginning persistent homology loop\n\n", color = :pink)
# Loop over graph files and run persistent homology. Store barcodes.
# for (i,graph_file) in enumerate(graph_files)
if occursin(DATE_STRING,graph_file)

    println("Starting persistent homology for $(graph_model)\n")

    # Load in weighted_graph_array

    const weighted_graph_array = load("$(read_dir)/$(graph_file)", "weighted_graph_array")

    # Ensure array is not all 0s
    if sum(weighted_graph_array)==0
        printstyled("ALL ENTRIES 0 IN GRAPH", color=:red)
    end

    # Find number of reps
    const nReps = size(weighted_graph_array)[3]

    # Prepare arrays
    barcodeArray = Array{Array{Float64}}(undef,nReps,MAXDIM)

    for rep in 1:nReps

        # Extract replicate
        G_i = weighted_graph_array[:,:,rep]

        # To run backwards, we want to flip the relative order of the weighted edges
        G_i_neg = (-G_i).+ 2*(maximum(G_i))
        G_i_neg[diagind(G_i_neg)] .= 0
        if rep == 1
            printstyled("Add a check for edge ranks here", color=:blue)
        end

        # G_i_neg is a weighted graph where the smallest original edges are greatest. We need to order it for Eirene
        edge_list_ranks = denserank([G_i_neg...], rev = true)   # so highest edge weight gets assigned 1
        G_i_ord = reshape(edge_list_ranks,(NNODES,NNODES))
        G_i_ord[diagind(G_i_ord)] .= 0

        # size of mat check
        printstyled("Input matrix size is $(size(G_i_ord))\n", color=:orange)

        # Run Eirene
        C = Eirene.eirene(G_i_ord,model = "vr", maxdim = MAXDIM, record = "none")
    
        # Store in barcodeArray
        for k in collect(1:MAXDIM)
            barcodeArray[rep, k] = barcode(C,dim=k)
        end

        if rep%10 == 0
            println("Run $(rep) completed.")
        end

        C = 0
    end


    printstyled("Completed computations for $(graph_model).\n", color = :green)

    # Save data
    const saveName = replace(graph_file, ".jld" => "")
    const saveName = replace(saveName, "_graphs" => "")
    if SAVEDATA == 1
        save("$(save_dir)/$(saveName)_$(SAVETAIL).jld",
            "barcodeArray", barcodeArray)
    end

    printstyled("Completed saving eirene outputs for $(graph_model).\n", color = :green)
    println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL).jld")
    printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)

else
    println("Incorrect date - skipping file")

end









