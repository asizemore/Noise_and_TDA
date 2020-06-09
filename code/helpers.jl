
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


# Take a graph and order the edges so that the highest edge is assigned 1.
function edge_weights_to_order(G_i,nNodes)
    edge_list_ranks = denserank([G_i...], rev = true)   # so highest edge weight gets assigned 1
    G_i_ord = reshape(edge_list_ranks,(nNodes,nNodes))
    G_i_ord[diagind(G_i_ord)] .= 0
    
    return G_i_ord
end

# Function for creating graphs based on graph model name and parameters
function construct_graphs(nNodes,nReps,rho,p,scale_factor, dims, a, b, graph_model_name)

    weighted_graph_array = Array{Union{Missing, Float64}}(missing, nNodes, nNodes, nReps)
    weighted_graph_array_ord = Array{Union{Missing, Float64}}(missing, nNodes, nNodes, nReps)
    betti_file_name = []
    parameters = []



    if graph_model_name == "geometricConf"
        for rep in 1:nReps

            # Construct the graph and fill weighted graph array
            G_i = make_dev_Geometric_configuration_model(nNodes,p,scale_factor)

            # Threshold at rho and fill weighted_graph_array
            weighted_graph_array[:,:,rep] = threshold_graph(G_i,rho,nNodes)

            # Order edges and fill weighted_graph_array_ord
            weighted_graph_array_ord[:,:,rep] = edge_weights_to_order(G_i,nNodes)
        end

        parameters = [nReps, rho, nNodes, p, scale_factor]
        betti_file_name = "$(graph_model_name)"

        for parameter in parameters
            betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        end


    elseif graph_model_name == "IID"
        for rep in 1:nReps
            # Construct the graph and fill weighted graph array
            G_i = make_iid_weighted_graph(nNodes)

            # Threshold at rho and fill weighted_graph_array
            weighted_graph_array[:,:,rep] = threshold_graph(G_i,rho,nNodes)

            # Order edges and fill weighted_graph_array_ord
            weighted_graph_array_ord[:,:,rep] = edge_weights_to_order(G_i,nNodes)
        end

        parameters = [nReps, rho, nNodes]
        betti_file_name = "$(graph_model_name)"

        for parameter in parameters
            betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        end


    elseif graph_model_name == "RG"
        for rep in 1:nReps

            # Construct the graph and fill weighted graph array
            G_i = make_random_geometric(nNodes,dims)

            # Threshold at rho and fill weighted_graph_array
            weighted_graph_array[:,:,rep] = threshold_graph(G_i,rho,nNodes)

            # Order edges and fill weighted_graph_array_ord
            weighted_graph_array_ord[:,:,rep] = edge_weights_to_order(G_i,nNodes)

        end

        parameters = [nReps, rho, nNodes, dims]
        betti_file_name = "$(graph_model_name)"

        for parameter in parameters
            betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        end


    elseif graph_model_name == "discreteUniformConf"
        for rep in 1:nReps

            # Construct the graph and fill weighted graph array
            G_i = make_dev_DiscreteUniform_configuration_model(nNodes,a,b)

            # Threshold at rho and fill weighted_graph_array
            weighted_graph_array[:,:,rep] = threshold_graph(G_i,rho,nNodes)

            # Order edges and fill weighted_graph_array_ord
            weighted_graph_array_ord[:,:,rep] = edge_weights_to_order(G_i,nNodes)

        end

        parameters = [nReps, rho, nNodes, a, b]
        betti_file_name = "$(graph_model_name)"

        for parameter in parameters
            betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        end


    elseif graph_model_name == "cosineGeometric"
        for rep in 1:nReps

            # Construct the graph and fill weighted graph array
            G_i = make_cosine_geometric(nNodes,dims)

            # Threshold at rho and fill weighted_graph_array
            weighted_graph_array[:,:,rep] = threshold_graph(G_i,rho,nNodes)

            # Order edges and fill weighted_graph_array_ord
            weighted_graph_array_ord[:,:,rep] = edge_weights_to_order(G_i,nNodes)

        end
        G_i = make_cosine_geometric(nNodes,dims)
        parameters = [nReps, rho, nNodes, dims]
        betti_file_name = "$(graph_model_name)"

        for parameter in parameters
            betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        end


    elseif graph_model_name == "RL"
         for rep in 1:nReps

            # Construct the graph and fill weighted graph array
            G_i = make_ring_lattice_wei(nNodes)

            # Threshold at rho and fill weighted_graph_array
            weighted_graph_array[:,:,rep] = threshold_graph(G_i,rho,nNodes)

            # Order edges and fill weighted_graph_array_ord
            weighted_graph_array_ord[:,:,rep] = edge_weights_to_order(G_i,nNodes)

        end

        parameters = [nReps, rho, nNodes]
        betti_file_name = "$(graph_model_name)"

        for parameter in parameters
            betti_file_name = "$(betti_file_name)_$(replace(string(parameter),"." => ""))"
        end


    elseif graph_model_name == "ASSOC"
        println("load data you fool")
    end







    println("Naming files $(betti_file_name)")

        # We can add noise to the entire array at the same time
    ## THis should be a function!!!
    weighted_graph_array_iidNoise = deepcopy(weighted_graph_array)
    weighted_graph_array_iidNoise_ord = Array{Union{Missing, Float64}}(missing, nNodes, nNodes, nReps)
    for rep in 1:nReps

        G_i = weighted_graph_array_iidNoise[:,:,rep]
        G_i[G_i.>0] .= G_i[G_i .>0 ] .+1

        # Now the real values are all >1, so we can add noise which will be < 1

        G_rand = make_iid_weighted_graph(nNodes)
        G_i_rand = deepcopy(G_i)
        G_i_rand[G_i_rand .== 0] .= G_rand[G_i_rand .== 0]

        # So anything <1 in G_i_rand will be from random noise, and any entry >1 will be real matrix

        weighted_graph_array_iidNoise[:,:,rep] = G_i_rand


        # Now create the ranked matrix for running eirene -- it will save us many headaches later.
        edge_list_ranks = denserank([G_i_rand...], rev = true)   # so highest edge weight gets assigned 1
        G_i_rand_ord = reshape(edge_list_ranks,(nNodes,nNodes))
        G_i_rand_ord[diagind(G_i_rand_ord)] .= 0


        weighted_graph_array_iidNoise_ord[:,:,rep] = G_i_rand_ord



    end
    
    return weighted_graph_array, weighted_graph_array_iidNoise, weighted_graph_array_iidNoise_ord, betti_file_name 
end



