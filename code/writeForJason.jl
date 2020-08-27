## Write mat files for jason


script_start_time = time()
println("\nimporting packages...")

using Pkg
using LinearAlgebra
using StatsBase
using JLD
using MAT


println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) \n \n", color = :yellow)



### Set parameters

const NREPS = 50
const NNODES = 70
const MAXDIM = 3
const NAMEID = "backward"
const NAMETAG = "backward"
read_dir = "./processed_data/results/$(NNODES)nodes"
save_dir = "./processed_data/forJason/$(NNODES)nodes"



### Locate data
betti_files = filter(x->occursin("_bettis.jld",x), readdir(read_dir))
betti_files = filter(x->occursin("$(NAMEID)",x), betti_files)
println("Located the following betti curve files:")
for betti_file in betti_files
    println(betti_file)
end

model_names_bettis = [split(betti_file,"_")[1] for betti_file in betti_files]

bettiBar_files = filter(x->occursin("_bettiBars.jld",x), readdir(read_dir))
bettiBar_files = filter(x->occursin("$(NAMEID)",x), bettiBar_files)
println("\nLocated the following bettiBar files:")
for bettiBar_file in bettiBar_files
    println(bettiBar_file)
end

model_names_bettiBars = [split(bettiBar_file,"_")[1] for bettiBar_file in bettiBar_files]

# Need to check that all models have BOTH bettiBar files and betti files
if model_names_bettiBars==model_names_bettis
    printstyled("\nAll models have all necessary data.\n", color = :green)
else 
    printstyled("Data missing from a file. Rerun calculate_bettis.jl and calculate_bettiBars.jl \n", color=:red)
end



## Read in all the data and create 4 mega arrays for betti curves, bettiBar, muBar, and nuBar values

nModels = length(betti_files)
nEdges = binomial(NNODES, 2)
betti_curve_array_all = zeros(NREPS,nEdges,MAXDIM,nModels)
bettiBar_all = zeros(NREPS,MAXDIM,nModels)
muBar_all = zeros(NREPS,MAXDIM,nModels)
nuBar_all = zeros(NREPS,MAXDIM,nModels)


for (i,betti_file) in enumerate(betti_files)

    # Read in Betti curve data and store
    betti_dict = load("$(read_dir)/$(betti_file)")
    betti_curve_array_all[:,:,:, i] = betti_dict["bettisArray"]

    bettiBar_dict = load("$(read_dir)/$(bettiBar_files[i])")
    bettiBar_all[:,:, i] = bettiBar_dict["bettiBarArray"]
    muBar_all[:,:, i] = bettiBar_dict["muBarArray"]
    nuBar_all[:,:, i] = bettiBar_dict["nuBarArray"]


end


### Save .mat file for jason

matwrite("$(save_dir)/all_betti_data_$(NAMETAG).mat", Dict("all_bettis_mat" => betti_curve_array_all, 
        "bettiBar_array" => bettiBar_all, 
        "muBar_array" => muBar_all,
        "nuBar_array" => nuBar_all))

printstyled("\nFinished saving file to $(save_dir)/all_betti_data_$(NAMETAG).mat\n", color=:green)
