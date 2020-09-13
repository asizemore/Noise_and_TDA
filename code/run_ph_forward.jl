### Run persistent homology


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



function fillBarcodeArray!(barcodeArray,weighted_graph_array,MAXDIM)

    nReps = size(weighted_graph_array, 3)
    nNodes = size(weighted_graph_array, 1)

    for rep in 1:nReps

        # Extract replicate
        # G_i = weighted_graph_array[:,:,rep]

        # G_i is a weighted graph. We need to order it
        edge_list_ranks = denserank([weighted_graph_array[:,:,rep]...], rev = true)   # so highest edge weight gets assigned 1

        G_i_ord = reshape(edge_list_ranks,(nNodes,nNodes))
        G_i_ord[diagind(G_i_ord)] .= 0

        # size of mat check
        printstyled("Input matrix size is $(size(G_i_ord))\n", color=:orange)

        # Precompile
        if rep == 1
            @time Eirene.eirene(G_i_ord,model = "vr", maxdim = MAXDIM, record = "none")
            @time Eirene.eirene(G_i_ord,model = "vr", maxdim = MAXDIM, record = "none")
        end



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

    return barcodeArray

end

function createAndFillBarcodeArray(nReps,MAXDIM, weighted_graph_array)

     # Prepare arrays
     barcodeArray = Array{Array{Float64}}(undef,nReps,MAXDIM)


     fillBarcodeArray!(barcodeArray,weighted_graph_array,MAXDIM)

     return barcodeArray
end





### Set parameters

config = read_config("$(pwd())/configs/$(ARGS[1])")

# Parameters for all graphs
const NNODES = config["NNODES"]
const SAVEDATA = config["SAVEDATA"]    # Boolean to save data  
const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
const SAVETAIL = config["SAVETAIL_ph_forward"]
const DATE_STRING = config["DATE_STRING"]
const HOMEDIR = config["HOMEDIR"]
const read_dir = "$(HOMEDIR)/$(config["read_dir_graphs"])/$(NNODES)nodes"
const save_dir = "$(HOMEDIR)/$(config["save_dir_results"])/$(NNODES)nodes"

### Read in from looping shell script
const graph_file =  split(ARGS[2],"/")[end]


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

    println("Starting persistent homology for $(graph_model)\n")

    # Load in weighted_graph_array
    const graph_dict = load("$(read_dir)/$(graph_file)")
    const weighted_graph_array = graph_dict["weighted_graph_array"]

    # Ensure array is not all 0s
    if sum(weighted_graph_array)==0
        printstyled("ALL ENTRIES 0 IN GRAPH", color=:red)
    end

    # Find number of reps
    const nReps = size(weighted_graph_array)[3]

    barcodeArray = createAndFillBarcodeArray(nReps,MAXDIM, weighted_graph_array)

    # # Prepare arrays
    # barcodeArray = Array{Array{Float64}}(undef,nReps,MAXDIM)


    # fillBarcodeArray!(barcodeArray,weighted_graph_array)

    # for rep in 1:nReps

    #     # Extract replicate
    #     G_i = weighted_graph_array[:,:,rep]

    #     # G_i is a weighted graph. We need to order it
    #     edge_list_ranks = denserank([G_i...], rev = true)   # so highest edge weight gets assigned 1
    #     G_i_ord = reshape(edge_list_ranks,(NNODES,NNODES))
    #     G_i_ord[diagind(G_i_ord)] .= 0

    #     # size of mat check
    #     printstyled("Input matrix size is $(size(G_i_ord))\n", color=:orange)


    #     # Run Eirene
    #     C = Eirene.eirene(G_i_ord,model = "vr", maxdim = MAXDIM, record = "none")
    
    #     # Store in barcodeArray
    #     for k in collect(1:MAXDIM)
    #         barcodeArray[rep, k] = barcode(C,dim=k)
    #     end

    #     if rep%10 == 0
    #         println("Run $(rep) completed.")
    #     end

    #     C = 0
    # end


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

# end









