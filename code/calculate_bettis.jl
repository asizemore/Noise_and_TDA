## Plot Betti curves for all models

script_start_time = time()
println("\nimporting packages...")

using Pkg
using Statistics
using LinearAlgebra
using Eirene
using StatsBase
using Random
using JLD
using MAT


println("packages imported")

println("importing functions...")

include("graph_models.jl")
include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)



### Set parameters

# Parameters for all graphs
const NNODES = 70
const MAXDIM = 3    # Maximum persistent homology dimension


### Locate data
read_dir = "./processed_data/results/$(NNODES)nodes"
eirene_files = filter(x->occursin("eireneoutput",x), readdir(read_dir))
println("Located the following graph files:")
for eirene_file in eirene_files
    println(eirene_file)
end


### Run through graphs and compute Betti curves 
nEdges = binomial(NNODES, 2)
for (i,eirene_file) in enumerate(eirene_files)

    println("Beginning $(eirene_file)")

    # Load in eirene output
    eirene_dict = load("$(read_dir)/$(eirene_file)")

    barcodeArray = eirene_dict["barcodeArray"]
    nReps = size(barcodeArray)[1]
    bettisArray = zeros(nReps,nEdges,MAXDIM)

    # Compute Betti curves
    for rep in 1:nReps
        for k in collect(1:MAXDIM)

            barcode_i = barcodeArray[rep, k]
            bettisArray[rep, :, k] = betticurveFromBarcode(barcode_i, nEdges)
        end
    end

    # Save bettisArray
    saveName = replace(eirene_file, ".jld"=> "")
    saveName = replace(saveName, "_eireneoutput" => "")
    save("./processed_data/results/$(NNODES)nodes/$(saveName)_bettis.jld",
            "bettisArray", bettisArray)
    
    printstyled("Completed saving Betti curves for $(saveName).\n", color = :green)
    println("Saved outputs to ./processed_data/results/$(NNODES)nodes/$(saveName)_bettis.jld")
    printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)


end


