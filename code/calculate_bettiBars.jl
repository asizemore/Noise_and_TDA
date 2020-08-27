## Compute Betti bar and other values

script_start_time = time()
println("\nimporting packages...")

using Pkg
using Statistics
using LinearAlgebra
using Distances
using StatsBase
using JLD

println("packages imported")

println("importing functions...")

include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)




### Set parameters

# Parameters for all graphs
const NNODES = 70
const MAXDIM = 3    # Maximum persistent homology dimension
const NAMETAG = "bettiBars"
read_dir = "./processed_data/results/$(NNODES)nodes"
save_dir = "./processed_data/results/$(NNODES)nodes"


### Locate data
eirene_files = filter(x->occursin("eireneoutput",x), readdir(read_dir))
println("Located the following barcode files:")
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
    bettiBarArray = zeros(nReps,MAXDIM)
    muBarArray = zeros(nReps,MAXDIM)
    nuBarArray = zeros(nReps,MAXDIM)

    # Compute Betti curves
    for rep in 1:nReps
        for k in collect(1:MAXDIM)

            barcode_i = barcodeArray[rep, k]

            bettiBarArray[rep, k] = bettiBarFromBarcode(barcode_i)
            muBarArray[rep, k] = muBarFromBarcode(barcode_i)
            nuBarArray[rep, k] = nuBarFromBarcode(barcode_i,nEdges)
        end
    end

    # Save bettisArray
    saveName = replace(eirene_file, ".jld"=> "")
    saveName = replace(saveName, "_eireneoutput" => "")
    save("$(save_dir)/$(saveName)_$(NAMETAG).jld",
            "bettiBarArray", bettiBarArray,
            "muBarArray", muBarArray,
            "nuBarArray", nuBarArray)
    
    printstyled("Completed saving Betti bar values for $(saveName).\n", color = :green)
    println("Saved outputs to $(save_dir)/$(saveName)_$(NAMETAG).jld")
    printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)


end

