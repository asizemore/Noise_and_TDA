## Write mat files for jason


script_start_time = time()
println("\nimporting packages...")

using Pkg
using LinearAlgebra
using StatsBase
using JLD
using JSON
using MAT
include("helper_functions.jl")


println("packages and functions imported")
printstyled("Elapsed time = $(time() - script_start_time) \n \n", color = :yellow)




### Set parameters
config = read_config("$(homedir())/configs/$(ARGS[1])")

const NNODES = config["NNODES"]
const NREPS = config["NREPS"]
const SAVEDATA = config["SAVEDATA"]    # Boolean to save data  
const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
const DATE_STRING = config["DATE_STRING"]
read_dir = "$(homedir())/$(config["read_dir_results"])/$(NNODES)nodes"
save_dir = "$(homedir())/$(config["save_dir_forJason"])/$(NNODES)nodes"



### Locate data
betti_files = filter(x->occursin("_bettis.jld",x), readdir(read_dir))
betti_files = filter(x -> occursin(DATE_STRING, x), betti_files)

## Exclude any?
betti_files = filter(x -> !occursin("backward", x), betti_files)
betti_files = filter(x -> !occursin("Triangle", x), betti_files)
betti_files = filter(x -> !occursin("clique", x), betti_files)


sort!(betti_files)
println("Located the following betti curve files:")
for betti_file in betti_files
    println(betti_file)
end

model_names_bettis = [split(betti_file,"_bettis")[1] for betti_file in betti_files]

bettiBar_files = filter(x->occursin("_bettiBars",x), readdir(read_dir))
bettiBar_files = filter(x -> occursin(DATE_STRING, x), bettiBar_files)




sort!(bettiBar_files)
println("\nLocated the following bettiBar files:")
for bettiBar_file in bettiBar_files
    println(bettiBar_file)
end

model_names_bettiBars = [split(bettiBar_file,"_bettiBar")[1] for bettiBar_file in bettiBar_files]



# Need to check that all models have BOTH bettiBar files and betti files
# if unique(model_names_bettiBars)==unique(model_names_bettis) && unique(model_names_bettiBars)==unique(model_names_netStats)
if unique(model_names_bettiBars)==unique(model_names_bettis)
    printstyled("\nAll models have all necessary data.\n", color = :green)
else 
    printstyled("Data missing from a file. Rerun calculate_bettis.jl and calculate_bettiBars.jl \n", color=:red)
end



# Locate the nametags
nametags = []
test = []

for betti_file in betti_files
    println(betti_file)
    tag = split(split(betti_file, "$(DATE_STRING)_")[2], "_bettis")[1]
    append!(nametags,[tag])
end


nametags = unique(nametags)
println(nametags)



for nametag in nametags

    betti_files_nametag = filter(x -> occursin("$(nametag)",x), betti_files)
    bettiBar_files_nametag = filter(x -> occursin("$(nametag)",x), bettiBar_files)
    model_names = [split(betti_file_nametag,"_")[1] for betti_file_nametag in betti_files_nametag]


    nModels = length(betti_files_nametag)
    nEdges = binomial(NNODES, 2)
    betti_curve_array_all = zeros(NREPS,nEdges,MAXDIM,nModels)
    bettiBar_all = zeros(NREPS,MAXDIM,nModels)
    muBar_all = zeros(NREPS,MAXDIM,nModels)
    nuBar_all = zeros(NREPS,MAXDIM,nModels)



    # Handle the threshold and non threshold types separately
    if occursin("thresh", nametag) && !occursin("noiseOnly", nametag) 

        ## Read in all the data and create mega arrays for betti curves, bettiBar, muBar, and nuBar values, for the whole, pre, and post noise scenarios
        bettiBar_all_prenoise = zeros(NREPS,MAXDIM,nModels)
        muBar_all_prenoise = zeros(NREPS,MAXDIM,nModels)
        nuBar_all_prenoise = zeros(NREPS,MAXDIM,nModels)

        bettiBar_all_postnoise = zeros(NREPS,MAXDIM,nModels)
        muBar_all_postnoise = zeros(NREPS,MAXDIM,nModels)
        nuBar_all_postnoise = zeros(NREPS,MAXDIM,nModels)

        bettiBar_all_crossover = zeros(NREPS,MAXDIM,nModels)
        muBar_all_crossover = zeros(NREPS,MAXDIM,nModels)
        nuBar_all_crossover = zeros(NREPS,MAXDIM,nModels)

        bettiBar_all_blues = zeros(NREPS,MAXDIM,nModels)
        muBar_all_blues = zeros(NREPS,MAXDIM,nModels)
        nuBar_all_blues = zeros(NREPS,MAXDIM,nModels)



        names_ordered = []

        for (i, betti_file_nametag) in enumerate(betti_files_nametag)

            # Read in Betti curve data and store
            betti_dict = load("$(read_dir)/$(betti_file_nametag)")
            betti_curve_array_all[:,:,:, i] = betti_dict["bettisArray"]

            # Set betti bar file base
            bettiBar_file_base = split(betti_files_nametag[i], "_bettis")[1]

            # Betti bars from all edges
            bettiBar_dict = load("$(read_dir)/$(bettiBar_file_base)_bettiBars.jld")
            bettiBar_all[:,:, i] = bettiBar_dict["bettiBarArray"]
            muBar_all[:,:, i] = bettiBar_dict["muBarArray"]
            nuBar_all[:,:, i] = bettiBar_dict["nuBarArray"]

            # Betti bars from prenoise
            bettiBar_dict = load("$(read_dir)/$(bettiBar_file_base)_bettiBars_prenoise.jld")
            bettiBar_all_prenoise[:,:, i] = bettiBar_dict["bettiBarArray"]
            muBar_all_prenoise[:,:, i] = bettiBar_dict["muBarArray"]
            nuBar_all_prenoise[:,:, i] = bettiBar_dict["nuBarArray"]

            # Betti bars from postnoise
            bettiBar_dict = load("$(read_dir)/$(bettiBar_file_base)_bettiBars_postnoise.jld")
            bettiBar_all_postnoise[:,:, i] = bettiBar_dict["bettiBarArray"]
            muBar_all_postnoise[:,:, i] = bettiBar_dict["muBarArray"]
            nuBar_all_postnoise[:,:, i] = bettiBar_dict["nuBarArray"]

            # Betti bars from crossover
            bettiBar_dict = load("$(read_dir)/$(bettiBar_file_base)_bettiBars_crossover.jld")
            bettiBar_all_crossover[:,:, i] = bettiBar_dict["bettiBarArray"]
            muBar_all_crossover[:,:, i] = bettiBar_dict["muBarArray"]
            nuBar_all_crossover[:,:, i] = bettiBar_dict["nuBarArray"]

            # Betti bars from crossover
            bettiBar_dict = load("$(read_dir)/$(bettiBar_file_base)_bettiBars_blues.jld")
            bettiBar_all_blues[:,:, i] = bettiBar_dict["bettiBarArray"]
            muBar_all_blues[:,:, i] = bettiBar_dict["muBarArray"]
            nuBar_all_blues[:,:, i] = bettiBar_dict["nuBarArray"]


            append!(names_ordered, [bettiBar_file_base])

        end

        ### Checks
        println(sum([bettiBar_all...]))
        println(sum([bettiBar_all_crossover...]))
        println(sum([bettiBar_all_blues...]))



        ### Save .mat file for jason

        matwrite("$(save_dir)/all_betti_data_$(nametag)_$(DATE_STRING).mat", Dict("betti_curve_array_all" => betti_curve_array_all, 
                "bettiBar_all" => bettiBar_all, 
                "muBar_all" => muBar_all,
                "nuBar_all" => nuBar_all,
                "bettiBar_all_prenoise" => bettiBar_all_prenoise,
                "muBar_all_prenoise"=> muBar_all_prenoise,
                "nuBar_all_prenoise" => nuBar_all_prenoise,
                "bettiBar_all_postnoise" => bettiBar_all_postnoise,
                "muBar_all_postnoise" => muBar_all_postnoise,
                "nuBar_all_postnoise" => nuBar_all_postnoise,
                "bettiBar_all_crossover" => bettiBar_all_crossover,
                "muBar_all_crossover" => muBar_all_crossover,
                "nuBar_all_crossover" => nuBar_all_crossover,
                "bettiBar_all_blues" => bettiBar_all_blues,
                "muBar_all_blues" => muBar_all_blues,
                "nuBar_all_blues" => nuBar_all_blues,
                "names_ordered" => names_ordered))


        printstyled("\nFinished saving file to $(save_dir)/all_betti_data_$(nametag)_$(DATE_STRING).mat\n", color=:green)





    elseif occursin("noiseOnly", nametag) 

        ## Read in all the data and create 4 mega arrays for betti curves, bettiBar, muBar, and nuBar values
        names_ordered = []

        for (i, betti_file_nametag) in enumerate(betti_files_nametag)

            # Read in Betti curve data and store
            println(betti_file_nametag)
            betti_dict = load("$(read_dir)/$(betti_file_nametag)")
            betti_curve_array_all[:,:,:, i] = deepcopy(betti_dict["bettisArray"])


            # Set betti bar file base
            bettiBar_file_base = split(betti_files_nametag[i], "_bettis")[1]


            println(bettiBar_file_base)
            bettiBar_dict = load("$(read_dir)/$(bettiBar_file_base)_bettiBars.jld")
            bettiBar_all[:,:, i] = bettiBar_dict["bettiBarArray"]
            muBar_all[:,:, i] = bettiBar_dict["muBarArray"]
            nuBar_all[:,:, i] = bettiBar_dict["nuBarArray"]



            append!(names_ordered, [bettiBar_file_base])


        end

         ### Checks
         println(sum([bettiBar_all...]))
         println(sum([muBar_all...]))
         println(sum([nuBar_all...]))


        ### Save .mat file for jason

        matwrite("$(save_dir)/all_betti_data_$(nametag)_$(DATE_STRING).mat", Dict("betti_curve_array_all" => betti_curve_array_all, 
                "bettiBar_all" => bettiBar_all, 
                "muBar_all" => muBar_all,
                "nuBar_all" => nuBar_all,
                "names_ordered" => names_ordered))


        printstyled("\nFinished saving file to $(save_dir)/all_betti_data_$(nametag)_$(DATE_STRING).mat\n", color=:green)

    else

        ## Read in all the data and create 4 mega arrays for betti curves, bettiBar, muBar, and nuBar values
        names_ordered = []

        for (i, betti_file_nametag) in enumerate(betti_files_nametag)

            # Read in Betti curve data and store
            println(betti_file_nametag)
            betti_dict = load("$(read_dir)/$(betti_file_nametag)")
            betti_curve_array_all[:,:,:, i] = deepcopy(betti_dict["bettisArray"])


            # Set betti bar file base
            bettiBar_file_base = split(betti_files_nametag[i], "_bettis")[1]


            println(bettiBar_file_base)
            bettiBar_dict = load("$(read_dir)/$(bettiBar_file_base)_bettiBars.jld")
            bettiBar_all[:,:, i] = bettiBar_dict["bettiBarArray"]
            muBar_all[:,:, i] = bettiBar_dict["muBarArray"]
            nuBar_all[:,:, i] = bettiBar_dict["nuBarArray"]

            append!(names_ordered, [bettiBar_file_base])


        end

         ### Checks
         println(sum([bettiBar_all...]))
         println(sum([muBar_all...]))
         println(sum([nuBar_all...]))




        ### Save .mat file for jason

        matwrite("$(save_dir)/all_betti_data_$(nametag)_$(DATE_STRING).mat", Dict("betti_curve_array_all" => betti_curve_array_all, 
                "bettiBar_all" => bettiBar_all, 
                "muBar_all" => muBar_all,
                "nuBar_all" => nuBar_all,
                "names_ordered" => names_ordered))


        printstyled("\nFinished saving file to $(save_dir)/all_betti_data_$(nametag)_$(DATE_STRING).mat\n", color=:green)

    end # ends if threshold 




end # end nametags loop