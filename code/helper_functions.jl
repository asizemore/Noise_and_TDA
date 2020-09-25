## Additional helpful functions


function check_density(G)
    
    # Determine number of nodes and edges
    nNodes = size(G,1)
    nPosEdges = length(G[G.> 0])./2    # Divide by 2 because this counts upper and lower triangular edges
    

    # Calculate the edge density as the number of nonzero edges over the total possible
    edge_density = nPosEdges./binomial(nNodes,2)
    
    return edge_density
end


function threshold_graph(G,rho,nNodes)
    
    # Count edges and edges we need to keep
    nEdges = binomial(nNodes,2)
    thresh_edge_number = ceil(Int,rho*nEdges)
    
    # Obtain value on which to threshold
    sorted_edges = sort(unique([G...]),rev = true)
    thresh_edge_value = sorted_edges[thresh_edge_number]
    
    # Make copy and threshold G
    G_thresh = deepcopy(G)
    G_thresh[G_thresh.< thresh_edge_value] .= 0
    
    # Test graph density
    rho_test = check_density(G_thresh)
    #println("Graph edge density is $rho_test")
    
    return G_thresh, thresh_edge_number
end


function betticurveFromBarcode(barcode,nSteps)
    # nSteps will be nEdges here

    betti_curve = zeros(1,nSteps)   # Column-major order

    for bar in eachrow(barcode)
    
        bar_first = Int(bar[1])
        bar_last = Int(bar[2]) 
    
        # Add to betti curve
        betti_curve[1,bar_first:bar_last] = betti_curve[1,bar_first:bar_last] .+1 
    end
    
    return betti_curve
end



function makeEdgeWeightsUnique(G)
    # If G does not have unique edge weights, add a small amount of noise to shift edge weights without changing relative ordering.
    
    nNodes = size(G)[1]
    
    # Get sorted, unique edge weights
    edgeWeights = sort([G...])
    edgeWeightsUnique = unique(edgeWeights)

    # Find the smallest difference between two neighboring edge weights
    edgeWeightDiffs = [edgeWeightsUnique[i] - edgeWeightsUnique[i-1] for i=2:length(edgeWeightsUnique)]
    noiseScale = 0.1 * minimum(edgeWeightDiffs)
    
    # Create a noise array that is scaled by 1/10th of the minimum edge weight difference
    noiseArray = noiseScale*rand(nNodes,nNodes)
    
    # Add to G and clean up graph
    G_u = G.+noiseArray
    G_u = (G_u .+ transpose(G_u))/2
    G_u[diagind(G_u)] .= 0

    # Check that we did not add too much noise
    if !(maximum(G_u .- G) < minimum(edgeWeightDiffs))
        printstyled("ERROR in making edge weights unique", color=:red)
    end
    
    return G_u
end




function bettiBarFromBarcode(barcode)
    
    bettiBar = 0
    
    for bar in eachrow(barcode)
        
        bar_birth = Int(bar[1])
        bar_death = Int(bar[2])
        
        lifetime = bar_death - bar_birth
        
        bettiBar = bettiBar + lifetime
    end
    
    return bettiBar
end


function muBarFromBarcode(barcode)
    
    muBar = 0
    
    for bar in eachrow(barcode)
        
        bar_birth = Int(bar[1])
        bar_death = Int(bar[2])
        
        lifetime_scaled = bar_birth*(bar_death - bar_birth)
        
        muBar = muBar + lifetime_scaled
    end
    
    return muBar
end
    

function nuBarFromBarcode(barcode,nSteps)
    
    # Assuming nSteps is the end of the filtration.
    
    nuBar = 0
    
    for bar in eachrow(barcode)
        
        bar_birth = Int(bar[1])
        bar_death = Int(bar[2])
        
        lifetime_scaled = (nSteps - bar_death)*(bar_death - bar_birth)
        
        nuBar = nuBar + lifetime_scaled
    end
    
    return nuBar
end


function read_config(config_file)
    # read configuration file into dictionary
    
    # Code from https://gist.github.com/silgon/0ba43e00e0749cdf4f8d244e67cd9d6a

    config = Dict()
    open(config_file, "r") do f
        config=JSON.parse(f)  # parse and transform data
    end
    
    return config
    
end


function fillBarcodeArray!(barcodeArray,weighted_graph_array,MAXDIM)

    nReps = size(weighted_graph_array, 3)
    nNodes = size(weighted_graph_array, 1)

    for rep in 1:nReps

        # Extract replicate
        # G_i = weighted_graph_array[:,:,rep]

        # G_i is a weighted graph. We need to order it
        edge_list_ranks::Array{Int64,1} = denserank([weighted_graph_array[:,:,rep]...], rev = true)   # so highest edge weight gets assigned 1

        G_i_ord::Array{Int64,2} = reshape(edge_list_ranks,(nNodes,nNodes))
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

        # C = 0
        

    end

    return barcodeArray

end

function createAndFillBarcodeArray(nReps::Int,MAXDIM::Int, weighted_graph_array::Array{Float64,3})

     # Prepare arrays
     barcodeArray = Array{Array{Float64}}(undef,nReps,MAXDIM)


     fillBarcodeArray!(barcodeArray,weighted_graph_array,MAXDIM)

     return barcodeArray
end


function triu_elements(a,k)
    
    # Assume a is square!
    if size(a)[1] !== size(a)[2]
        println("Input a square matrix")
    else 
        vec = [a[i, j] for j in collect(1:size(a)[1]) for i in 1:(j-k)]
        return vec
    end
end


function randomize_edge_weights(adj)

    # For any non-zero edges, give them random weights. Since we only care about the ordering, this will have the same effect
    # as randomly permuting the original edge weights.
    nNodes = size(adj)[1]
    adj_rand = copy(adj)
    adj_rand[adj_rand.>0] .=1
    noiseyG = make_iid_weighted_graph(nNodes)
    adj_rand[adj_rand .==1] .= noiseyG[adj_rand.==1]
    
    return adj_rand
end
        
