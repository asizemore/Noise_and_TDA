## Loop through files locally and run persistent homolgy

## Need to define globally the variable newARGS = [configfile, run_ph_file], for example newARGS = ["config091520.json", "run_ph_thresholds.jl"]

println("Running local_loop.jl")

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


### Set parameters
localARGS = isdefined(Main,:newARGS) ? newARGS : ARGS

config = read_config("$(pwd())/configs/$(localARGS[1])")

# Parameters for all graphs
NNODES = config["NNODES"]
# const SAVEDATA = config["SAVEDATA"]    # Boolean to save data  
# const MAXDIM = config["MAXDIM"]    # Maximum persistent homology dimension
# const SAVETAIL = config["SAVETAIL_ph_forward"]
DATE_STRING = config["DATE_STRING"]
HOMEDIR = config["HOMEDIR"]
read_dir = "$(homedir())/$(config["read_dir_thresh"])/$(NNODES)nodes"


### Read in from looping shell script
run_ph_file =  localARGS[2]


### Locate data
graph_files = filter(x->occursin("graphs",x), readdir(read_dir))
graph_files = filter(x->occursin("randomized",x), readdir(read_dir))


graph_files = filter(x -> occursin(DATE_STRING,x), graph_files)


#### OPTIONAL filtering
# graph_files = filter(x -> occursin("disass",x), graph_files)
# graph_files = filter(x -> occursin("1449",x), graph_files)
##########


println("Located the following graph files:")
for graph_file in graph_files
    println(graph_file)
end



for graph_file in graph_files

    global loopARGS = [localARGS[1], graph_file]

    println("Starting $(run_ph_file) on graph $(graph_file)")

    include(run_ph_file)

    println("Finished $(run_ph_file) on graph $(graph_file)")

end


printstyled("Loop complete!", color=:pink)



