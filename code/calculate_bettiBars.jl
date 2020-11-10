## Compute Betti bar and other values

script_start_time = time()
println("\nimporting packages...")

using Pkg
using Statistics
using LinearAlgebra
using Distances
using StatsBase
using JLD
using JSON

println("packages imported")

println("importing functions...")

include("helper_functions.jl")

println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)




### Set parameters
config = read_config("$(homedir())/configs/$(ARGS[1])")

const NNODES = config["NNODES"]
# const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
const SAVETAIL = config["SAVETAIL_bettiBars"]
const DATE_STRING = config["DATE_STRING"]
read_dir = "$(homedir())/$(config["read_dir_results"])/$(NNODES)nodes"
save_dir = "$(homedir())/$(config["save_dir_results"])/$(NNODES)nodes"

### Locate data
eirene_files = filter(x->occursin("eireneoutput",x), readdir(read_dir))
eirene_files = filter(x -> occursin(DATE_STRING, x), eirene_files)

### Optional filtering
# eirene_files = filter(x -> !occursin("randomized", x), eirene_files)
####

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
    maxdim = size(barcodeArray)[2]
    bettiBarArray = zeros(nReps,maxdim)
    muBarArray = zeros(nReps,maxdim)
    nuBarArray = zeros(nReps,maxdim)

    # Compute Betti bar values

    for rep in 1:nReps
        for k in collect(1:maxdim)

            barcode_i = barcodeArray[rep, k]

            bettiBarArray[rep, k] = bettiBarFromBarcode(barcode_i)
            muBarArray[rep, k] = muBarFromBarcode(barcode_i)
            nuBarArray[rep, k] = nuBarFromBarcode(barcode_i,nEdges)
        end
    end


    # Check
    println(sum([bettiBarArray...]))
    println(sum([muBarArray...]))
    println(sum([nuBarArray...]))


    # Save bettisArray
    saveName = replace(eirene_file, ".jld"=> "")
    saveName = replace(saveName, "_eireneoutput" => "")
    save("$(save_dir)/$(saveName)_$(SAVETAIL).jld",
            "bettiBarArray", bettiBarArray,
            "muBarArray", muBarArray,
            "nuBarArray", nuBarArray)
    
    println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL).jld")
            
            
            
    # If the file is of threshold type, we want to compute values for the first half and second half as well
    if occursin("threshold", eirene_file)

        println("Splitting into prenoise and postnoise sections...")

        bettiBarArray_prenoise = zeros(nReps,maxdim)
        muBarArray_prenoise = zeros(nReps,maxdim)
        nuBarArray_prenoise = zeros(nReps,maxdim)

        bettiBarArray_postnoise = zeros(nReps,maxdim)
        muBarArray_postnoise = zeros(nReps,maxdim)
        nuBarArray_postnoise = zeros(nReps,maxdim)

        bettiBarArray_crossover = zeros(nReps,maxdim)
        muBarArray_crossover = zeros(nReps,maxdim)
        nuBarArray_crossover = zeros(nReps,maxdim)

        bettiBarArray_blues = zeros(nReps,maxdim)
        muBarArray_blues = zeros(nReps,maxdim)
        nuBarArray_blues = zeros(nReps,maxdim)

        # Find threshold edge number. Occurs between "edge" and "_"
        thresh_string = split(split(eirene_file,"edge")[2],"_")[1]
        threshold_edge = parse(Int, thresh_string)
        println("processing threshold edge $(threshold_edge)")

        for rep in 1:nReps
            for k in collect(1:maxdim)

                
                # Compute prenoise betti bar values. Set all barcode values greater than the threshold edge to the threshold edge number
                barcode_prenoise = deepcopy(barcodeArray[rep, k])
                barcode_prenoise[barcode_prenoise.> threshold_edge].= threshold_edge

                # Calculate values
                bettiBarArray_prenoise[rep, k] = bettiBarFromBarcode(barcode_prenoise)
                muBarArray_prenoise[rep, k] = muBarFromBarcode(barcode_prenoise)
                nuBarArray_prenoise[rep, k] = nuBarFromBarcode(barcode_prenoise,nEdges)


                # Compute postnoise betti bar values. Set all barcode values less than the threshold edge to the threshold edge number
                barcode_postnoise = deepcopy(barcodeArray[rep, k])
                barcode_postnoise[barcode_postnoise.<= threshold_edge].= threshold_edge+1

                # Calculate values
                bettiBarArray_postnoise[rep, k] = bettiBarFromBarcode(barcode_postnoise)
                muBarArray_postnoise[rep, k] = muBarFromBarcode(barcode_postnoise)
                nuBarArray_postnoise[rep, k] = nuBarFromBarcode(barcode_postnoise,nEdges)


                # Compute crossover betti bar values. Set all barcode values less than the threshold edge to the threshold edge number
                barcode_crossover = deepcopy(barcodeArray[rep, k])
                barcode_crossover = barcode_crossover[(barcode_crossover[:,1] .<= threshold_edge) .& (barcode_crossover[:,2] .> threshold_edge),:]

                # For consistency, set every barcode value less than the threshold edge equal to the thresold edge number
                barcode_crossover[barcode_crossover.<= threshold_edge].= threshold_edge+1

                # Calculate values
                bettiBarArray_crossover[rep, k] = bettiBarFromBarcode(barcode_crossover)
                muBarArray_crossover[rep, k] = muBarFromBarcode(barcode_crossover)
                nuBarArray_crossover[rep, k] = nuBarFromBarcode(barcode_crossover,nEdges)


                # Compute crossover betti bar values. Set all barcode values less than the threshold edge to the threshold edge number
                barcode_blues = deepcopy(barcodeArray[rep, k])
                barcode_blues = barcode_blues[(barcode_blues[:,1] .> threshold_edge) .& (barcode_blues[:,2] .> threshold_edge),:]

                # Calculate values
                bettiBarArray_blues[rep, k] = bettiBarFromBarcode(barcode_blues)
                muBarArray_blues[rep, k] = muBarFromBarcode(barcode_blues)
                nuBarArray_blues[rep, k] = nuBarFromBarcode(barcode_blues,nEdges)


            end # ends dimensions loop
        end # ends replicate loop



        
        
        # Save bettisArray of pre and post noise sections
        save("$(save_dir)/$(saveName)_$(SAVETAIL)_prenoise.jld",
        "bettiBarArray", bettiBarArray_prenoise,
        "muBarArray", muBarArray_prenoise,
        "nuBarArray", nuBarArray_prenoise)
        println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL)_prenoise.jld")
        
        save("$(save_dir)/$(saveName)_$(SAVETAIL)_postnoise.jld",
        "bettiBarArray", bettiBarArray_postnoise,
        "muBarArray", muBarArray_postnoise,
        "nuBarArray", nuBarArray_postnoise)

        save("$(save_dir)/$(saveName)_$(SAVETAIL)_crossover.jld",
        "bettiBarArray", bettiBarArray_crossover,
        "muBarArray", muBarArray_crossover,
        "nuBarArray", nuBarArray_crossover)

        save("$(save_dir)/$(saveName)_$(SAVETAIL)_blues.jld",
        "bettiBarArray", bettiBarArray_blues,
        "muBarArray", muBarArray_blues,
        "nuBarArray", nuBarArray_blues)
        
        println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL)_postnoise.jld")
        
        
        
    end # ends if threshold 


    if occursin("dsi",eirene_file)

        # We do special stuff for the dsi
        # We need to load in the threshold edge for each graph
        dsi_thresh_array = load("$(homedir())/processed_data/graphs/70nodes/dsi_matrices_091720_graphs.jld", "nnz_edges")


        println("Splitting into prenoise and postnoise sections...")

        bettiBarArray_prenoise = zeros(nReps,maxdim)
        muBarArray_prenoise = zeros(nReps,maxdim)
        nuBarArray_prenoise = zeros(nReps,maxdim)

        bettiBarArray_postnoise = zeros(nReps,maxdim)
        muBarArray_postnoise = zeros(nReps,maxdim)
        nuBarArray_postnoise = zeros(nReps,maxdim)

        bettiBarArray_crossover = zeros(nReps,maxdim)
        muBarArray_crossover = zeros(nReps,maxdim)
        nuBarArray_crossover = zeros(nReps,maxdim)

        bettiBarArray_blues = zeros(nReps,maxdim)
        muBarArray_blues = zeros(nReps,maxdim)
        nuBarArray_blues = zeros(nReps,maxdim)

        for rep in collect(1:nReps)

            threshold_edge = dsi_thresh_array[rep]

            for k in collect(1:maxdim)

                
                # Compute prenoise betti bar values. Set all barcode values greater than the threshold edge to the threshold edge number
                barcode_prenoise = deepcopy(barcodeArray[rep, k])
                barcode_prenoise[barcode_prenoise.> threshold_edge].= threshold_edge

                # Calculate values
                bettiBarArray_prenoise[rep, k] = bettiBarFromBarcode(barcode_prenoise)
                muBarArray_prenoise[rep, k] = muBarFromBarcode(barcode_prenoise)
                nuBarArray_prenoise[rep, k] = nuBarFromBarcode(barcode_prenoise,nEdges)


                # Compute postnoise betti bar values. Set all barcode values less than the threshold edge to the threshold edge number
                barcode_postnoise = deepcopy(barcodeArray[rep, k])
                barcode_postnoise[barcode_postnoise.<= threshold_edge].= threshold_edge+1

                # Calculate values
                bettiBarArray_postnoise[rep, k] = bettiBarFromBarcode(barcode_postnoise)
                muBarArray_postnoise[rep, k] = muBarFromBarcode(barcode_postnoise)
                nuBarArray_postnoise[rep, k] = nuBarFromBarcode(barcode_postnoise,nEdges)


                # Compute crossover betti bar values. Set all barcode values less than the threshold edge to the threshold edge number
                barcode_crossover = deepcopy(barcodeArray[rep, k])
                barcode_crossover = barcode_crossover[(barcode_crossover[:,1] .<= threshold_edge) .& (barcode_crossover[:,2] .> threshold_edge),:]

                # For consistency, set every barcode value less than the threshold edge equal to the thresold edge number
                barcode_crossover[barcode_crossover.<= threshold_edge].= threshold_edge+1

                # Calculate values
                bettiBarArray_crossover[rep, k] = bettiBarFromBarcode(barcode_crossover)
                muBarArray_crossover[rep, k] = muBarFromBarcode(barcode_crossover)
                nuBarArray_crossover[rep, k] = nuBarFromBarcode(barcode_crossover,nEdges)


                # Compute crossover betti bar values. Set all barcode values less than the threshold edge to the threshold edge number
                barcode_blues = deepcopy(barcodeArray[rep, k])
                barcode_blues = barcode_blues[(barcode_blues[:,1] .> threshold_edge) .& (barcode_blues[:,2] .> threshold_edge),:]

                # Calculate values
                bettiBarArray_blues[rep, k] = bettiBarFromBarcode(barcode_blues)
                muBarArray_blues[rep, k] = muBarFromBarcode(barcode_blues)
                nuBarArray_blues[rep, k] = nuBarFromBarcode(barcode_blues,nEdges)


            end # ends dimensions loop

        end # ends replicates loop


        # Save bettisArray of pre and post noise sections
        save("$(save_dir)/$(saveName)_$(SAVETAIL)_prenoise.jld",
        "bettiBarArray", bettiBarArray_prenoise,
        "muBarArray", muBarArray_prenoise,
        "nuBarArray", nuBarArray_prenoise)
        println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL)_prenoise.jld")
        
        save("$(save_dir)/$(saveName)_$(SAVETAIL)_postnoise.jld",
        "bettiBarArray", bettiBarArray_postnoise,
        "muBarArray", muBarArray_postnoise,
        "nuBarArray", nuBarArray_postnoise)

        save("$(save_dir)/$(saveName)_$(SAVETAIL)_crossover.jld",
        "bettiBarArray", bettiBarArray_crossover,
        "muBarArray", muBarArray_crossover,
        "nuBarArray", nuBarArray_crossover)

        save("$(save_dir)/$(saveName)_$(SAVETAIL)_blues.jld",
        "bettiBarArray", bettiBarArray_blues,
        "muBarArray", muBarArray_blues,
        "nuBarArray", nuBarArray_blues)
        
        println("Saved outputs to $(save_dir)/$(saveName)_$(SAVETAIL)_postnoise.jld")



    end # ends if dsi 
            
            
    printstyled("Completed saving Betti bar values for $(saveName).\n", color = :green)
    printstyled("Elapsed time = $(time() - script_start_time) seconds \n \n", color = :yellow)


end # ends eirene_files loop