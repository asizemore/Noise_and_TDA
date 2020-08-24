## Helper functions


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
    println("Thresholding at edge number $(thresh_edge_number)")
    
    # Obtain value on which to threshold
    sorted_edges = sort(unique([G...]),rev = true)
    thresh_edge_value = sorted_edges[thresh_edge_number]
    
    # Make copy and threshold G
    G_thresh = deepcopy(G)
    G_thresh[G_thresh.< thresh_edge_value] .= 0
    
    # Test graph density
    rho_test = check_density(G_thresh)
    #println("Graph edge density is $rho_test")
    
    return G_thresh
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