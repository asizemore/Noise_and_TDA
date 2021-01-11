### Run persistent homology
## Arguments: config_file, graph_file

println("Running run_ph_forward.jl")

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



### Set parameters -- use local loop arguments or those supplied by the shell script
localARGS = @isdefined(loopARGS) ? loopARGS : ARGS
println(localARGS)

config = read_config("$(pwd())/configs/$(localARGS[1])")

# Parameters for all graphs
NNODES = config["NNODES"]
const SAVEDATA = config["SAVEDATA"]    # Boolean to save data  
const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
const SAVETAIL = config["SAVETAIL_ph_forward"]
DATE_STRING = config["DATE_STRING"]
HOMEDIR = config["HOMEDIR"]
read_dir = "$(HOMEDIR)/$(config["read_dir_graphs"])/$(NNODES)nodes"
save_dir = "$(HOMEDIR)/$(config["save_dir_results"])/$(NNODES)nodes"

### Read in from looping shell script
const graph_file =  split(localARGS[2],"/")[end]


### Locate graphs to read
println("Located the following graph file:")
println(graph_file)


### Read in file and run PH
const graph_model = split(graph_file, "_")[1]
println("Identified the graph model: $(graph_model)")

const nEdges = binomial(NNODES, 2)

# Ensure we have the correct date
if occursin(DATE_STRING,graph_file)



    # Load in weighted_graph_array
    const weighted_graph_array = load("$(read_dir)/$(graph_file)", "weighted_graph_array")

    # Ensure array is not all 0s
    if sum(weighted_graph_array)==0
        printstyled("ALL ENTRIES 0 IN GRAPH", color=:red)
    end

    # Find number of reps
    const nReps = size(weighted_graph_array)[3]

    # Start persistent homology using Eirene
    println("Starting persistent homology for $(graph_model)\n")

    barcodeArray = createAndFillBarcodeArray(nReps,MAXDIM, weighted_graph_array)

    printstyled("Completed computations for $(graph_model).\n", color = :green)

    # Save data
    saveName = replace(graph_file, ".jld" => "")
    saveName = replace(saveName, "_graphs" => "")

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

# end









