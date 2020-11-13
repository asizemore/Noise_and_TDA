## Plot Betti curves for all models

script_start_time = time()
println("\nimporting packages...")

using Statistics
using LinearAlgebra
using StatsBase
using Random
using JLD
using JSON


println("packages imported")

println("importing functions...")

include("graph_models.jl")
include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)



### Set parameters
config = read_config("$(pwd())/configs/$(ARGS[1])")

const NNODES = config["NNODES"]
# const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
const SAVETAIL = config["SAVETAIL_bettis"]
const DATE_STRING = config["DATE_STRING"]
# const HOMEDIR = config["HOMEDIR"]
read_dir = "$(homedir())/$(config["read_dir_results"])/$(NNODES)nodes"
save_dir = "$(homedir())/$(config["save_dir_results"])/$(NNODES)nodes"

println("read_dir")

### Locate data
eirene_files = filter(x->occursin("eireneoutput",x), readdir(read_dir))
println(size(eirene_files))
eirene_files = filter(x->occursin(DATE_STRING,x), eirene_files)


### Optional filtering
eirene_files = filter(x->!occursin("randomized",x), eirene_files)
eirene_files = filter(x->!occursin("clique",x), eirene_files)
eirene_files = filter(x->!occursin("Triangle",x), eirene_files)
eirene_files = filter(x->!occursin("forward",x), eirene_files)
###

println("Located the following graph files:")
for eirene_file in eirene_files
    println(eirene_file)
end


### Run through graphs and compute Betti curves 

for (i,eirene_file) in enumerate(eirene_files)

    println("Beginning $(eirene_file)")

    localARGS = @isdefined(loopARGS) ? loopARGS : ARGS
    nNodes = occursin("dsi",eirene_file) ? 234 : config["NNODES"]
    nEdges = binomial(nNodes,2)

    # Load in eirene output
    eirene_dict = load("$(read_dir)/$(eirene_file)")

    barcodeArray = eirene_dict["barcodeArray"]
    nReps = size(barcodeArray)[1]
    maxdim = size(barcodeArray)[2]
    bettisArray = zeros(nReps,nEdges,maxdim)

    # Compute Betti curves
    for rep in 1:nReps
        for k in collect(1:maxdim)

            barcode_i = barcodeArray[rep, k]
            bettisArray[rep, :, k] = betticurveFromBarcode(barcode_i, nEdges)
        end
    end

    # Save bettisArray
    saveName = replace(eirene_file, ".jld"=> "")
    saveName = replace(saveName, "_eireneoutput" => "")
    save("./processed_data/results/$(NNODES)nodes/$(saveName)_$(SAVETAIL).jld",
            "bettisArray", bettisArray)
    
    printstyled("Completed saving Betti curves for $(saveName).\n", color = :green)
    println("Saved outputs to ./processed_data/results/$(NNODES)nodes/$(saveName)_$(SAVETAIL).jld")
    printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)


end



