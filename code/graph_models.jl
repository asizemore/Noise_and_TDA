# Graph model functions


function is_symmetric(adj)
    tf = isequal(adj,transpose(adj))
    if !tf
        println("Matrix is not symmetric!")
    end
    return tf
end



function make_iid_weighted_graph(nNodes)
    
    adj = rand(nNodes,nNodes)
    for i = 1:nNodes, j = 1:nNodes
        # symmetrize
        adj[j,i] = adj[i,j]
    end
    
    # Set diagonal to 0
    adj[diagind(adj)] .= 0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    # Return adjacency matrix
    return adj
end
    

function make_random_geometric(nNodes,dims)
    
    # Generate random coordinates in [0,1)^dims
    randomCoordinates = rand(dims,nNodes)
    
    # Compute pairwise distances between nodes (points in [0,1)^dims)
    adj = pairwise(Euclidean(), randomCoordinates, dims = 2)
    adj = 1 ./adj
    adj[diagind(adj)] .= 0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end


function make_ring_lattice_wei(nNodes)
    # Create weighted ring lattice
    
    if !iseven(nNodes)
        v = ones(1,(nNodes-1))./ [transpose(collect(1:floor(nNodes/2))) transpose(reverse(collect(1:floor(nNodes/2))))]
        v = [0 v]
        adj = deepcopy(v)
        for n in 1:(nNodes-1)
            adj = [adj; zeros(1,n) transpose(v[1,1:(nNodes-n)])]
        end
        # adj = adj .+ (1/(nNodes^4))*rand(nNodes,nNodes)
        adj = adj+transpose(adj)
        adj[diagind(adj)].=0

    else 
        v = ones(1,(nNodes-1))./ [transpose(collect(1:(nNodes/2))) transpose(reverse(collect(1:(nNodes/2 -1))))]
        v = [0 v]
        adj = deepcopy(v)
        for n in 1:(nNodes-1)
            adj = [adj; zeros(1,n) transpose(v[1,1:(nNodes-n)])]
        end
        # adj = adj .+ (1/(nNodes^4))*rand(nNodes,nNodes)
        adj = adj+transpose(adj)
        adj[diagind(adj)].=0
        
        
    end

    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end


function make_cosine_geometric(nNodes,dims)
    
    # Generate random coordinates in [0,1)^dims
    randomCoordinates = rand(dims,nNodes)
    
    # Compute pairwise distances between nodes (points in [0,1)^dims)
    adj = pairwise(CosineDist(), randomCoordinates, dims = 2)
    adj = 1 ./adj
    adj[diagind(adj)] .= 0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end


function make_squared_euclidean(nNodes,dims)
    
    # Generate random coordinates in [0,1)^dims
    randomCoordinates = rand(dims,nNodes)
    
    # Compute pairwise distances between nodes (points in [0,1)^dims)
    adj = pairwise(SqEuclidean(), randomCoordinates, dims = 2)
    adj = 1 ./adj
    adj[diagind(adj)] .= 0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end


function make_RMSDeviation(nNodes,dims)
    
    # Generate random coordinates in [0,1)^dims
    randomCoordinates = rand(dims,nNodes)
    
    # Compute pairwise distances between nodes (points in [0,1)^dims)
    adj = pairwise(RMSDeviation(), randomCoordinates, dims = 2)
    adj = 1 ./adj
    adj[diagind(adj)] .= 0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end




function make_dot_product(nNodes,dims)
    # Generate random coordinates in [0,1)^dims
    randomCoordinates = rand(dims,nNodes)
    
    # Compute pairwise distances between nodes (points in [0,1)^dims)
    adj = randomCoordinates' * randomCoordinates
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end


 
function make_dev_DiscreteUniform_configuration_model(nNodes,a,b)
    
    # Create a configuration model using the discrete uniform distribution between a and b.
    
    # Define distribution
    d = DiscreteUniform(a,b)
    strength_sequence = rand(d,nNodes)

    stubs = deepcopy(strength_sequence)
    adj = zeros(nNodes,nNodes)

    nodes_left = []
    # While stubs are left
    while sum(stubs)>0

        # Find which nodes have stubs left
        nodes_left = findall(stubs.>0)

        # If only one node is left, we did badly
        if length(nodes_left) == 1
            println("One node left - try again")
            
            # Currently this is a draft so we will allow it.
            break
        end


        # nodes_left contains cartesian indices. Can access them with nodes_left[i][j]. Not anymore
        node1,node2 = sample(nodes_left,2, replace = false)

        # Add edge to adjacency matrix
        adj[node1, node2] = adj[node1, node2] + 1 

        # Update stubs
        stubs[node1] = stubs[node1] - 1
        stubs[node2] = stubs[node2] - 1

        
    end

    # Now we only added edges to one side of the adjacency matrix.
    # adj = adj+adj'
    
    # Add noise
    # adj = adj .+ (1/(nNodes^4))*rand(nNodes,nNodes)
    adj = adj+transpose(adj)
    adj[diagind(adj)].=0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end





function make_dev_Geometric_configuration_model(nNodes,p,scale_factor)
    
    # Create a configuration model using the Geometric distribution with parameter p. To get enough edges,
    # scale by scale_factor
    
    # Define distribution
    d = Geometric(p)
    strength_sequence = scale_factor*rand(d,nNodes)

    stubs = deepcopy(strength_sequence)
    adj = zeros(nNodes,nNodes)

    nodes_left = []
    # While stubs are left
    while sum(stubs)>0

        # Find which nodes have stubs left
        nodes_left = findall(stubs.>0)

        # If only one node is left, we did badly
        if length(nodes_left) == 1
            println("One node left - draft")
            
            # Currently this is a draft so we will allow it.
            break
        end


        # nodes_left contains cartesian indices. Can access them with nodes_left[i][j]. Not anymore
        node1,node2 = sample(nodes_left,2, replace = false)

        # Add edge to adjacency matrix
        adj[node1, node2] = adj[node1, node2] + 1 

        # Update stubs
        stubs[node1] = stubs[node1] - 1
        stubs[node2] = stubs[node2] - 1

        
    end

    # Now we only added edges to one side of the adjacency matrix.
    # adj = adj+adj'
    
    # Add noise
    # adj = adj .+ (1/(nNodes^4))*rand(nNodes,nNodes)
    adj = adj+transpose(adj)
    adj[diagind(adj)].=0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end


function load_matlab_model(nNodes,rep, graph_name, parameters)
    # load in SWBMs we made in matlab
    # ./data/disassortative_WSBM_70_10_10_2_2_09_05.mat

    fullname = "$(homedir())/data/$(graph_name)_$(nNodes)_$(parameters)"

    mat_dict = matread("$(fullname).mat")
    G_i = mat_dict["adj_array"][:,:,rep]
    G_i = G_i+transpose(G_i)

    return G_i
end


function make_wsbm(nNodes, R, theta_w, groupSizes)
    ### Based on the Weighted Stochastic Block Model defined in:
    ### Aicher, Christopher Vinyu, "The Weighted Stochastic Block Model" (2014). Applied Mathematics Graduate Theses & Dissertations. 50.
    ### https://scholar.colorado.edu/appm_gradetds/50
    ###
    ### This code is adapted from the original matlab code functions generateEdges and Edge2Adj within the matlab package
    ### found here: http://tuvalu.santafe.edu/~aaronc/wsbm/
    ### Unlike the original code, the below assumes the edge weights come from a Normal distribution and that all
    ### edges will exist in the final graph (no sparsity control). Additionally, this code will force the output adjacency
    ### matrix to be symmetric, so ensure that R is symmetric for proper output.

    # Ensure R is symmetric
    tf = is_symmetric(R)

    adj = zeros((nNodes,0))

    # Build adj block by block
    for (j,col) in enumerate(eachcol(R))

        # Prepare for new column of blocks
        newcol = zeros((0,groupSizes[j]))

        for (i,row) in enumerate(eachrow(R))

            block = rand(Normal(theta_w[R[i,j],1],theta_w[R[i,j],2]),(groupSizes[i],groupSizes[j]))
            newcol = [newcol; block]

        end

        adj = [adj newcol]

    end

    # Make symmetric
    adj = adj+adj'

    # Set diagonal to 0
    adj[diagind(adj)].=0

    # Set any weight <0 to 0
    adj[adj.<0].=0
    
    return adj
end



function make_assortative4(nNodes,  mu_1, s_1, mu_2, s_2)
    ### Generate an assortative wsbm with four communities and even group sizes.

    R = [1 2 2 2; 2 1 2 2; 2 2 1 2; 2 2 2 1]

    theta_w = [mu_1 s_1; mu_2 s_2]

    # Assign even group sizes
    groupSizes = Int.([ceil(nNodes/4) ceil(nNodes/4) ceil(nNodes/4) nNodes-3*ceil(nNodes/4)])

    adj = make_wsbm(nNodes, R, theta_w, groupSizes)

    return adj
end


function make_disassortative4(nNodes, mu_1, s_1, mu_2, s_2)
    ### Generate an assortative wsbm with four communities and even group sizes.

    R = [2 1 1 1; 1 2 1 1; 1 1 2 1; 1 1 1 2];

    theta_w = [mu_1 s_1; mu_2 s_2]

    # Assign even group sizes
    groupSizes = Int.([ceil(nNodes/4) ceil(nNodes/4) ceil(nNodes/4) nNodes-3*ceil(nNodes/4)])

    adj = make_wsbm(nNodes, R, theta_w, groupSizes)

    return adj
end


function make_coreperiph4(nNodes,  mu_1, s_1, mu_2, s_2)
    ### Generate an assortative wsbm with four communities and even group sizes.

    R = [1 1 1 1; 1 2 2 2; 1 2 2 2; 1 2 2 2];

    theta_w = [mu_1 s_1; mu_2 s_2]

    # Assign even group sizes
    groupSizes = Int.([ceil(nNodes/4) ceil(nNodes/4) ceil(nNodes/4) nNodes-3*ceil(nNodes/4)])

    adj = make_wsbm(nNodes, R, theta_w, groupSizes)

    return adj
end



function make_probtriangle(nNodes, p)
    ### Control how much we force triangles to from

    ## triangle graph model

    nEdges = binomial(nNodes,2)
    adj = zeros(nNodes,nNodes)

    edges_left = copy(nEdges)

    while edges_left > 0
                    
        # Flip a coin
        r = rand(1)[1]

        if r < p  # See if there's a triangle and if there is, add it. If not, add edge randomly

            # Are any triangles possible?
            adj_2 = adj^2
            adj_2[diagind(adj_2)] .= 0
            
            possible_ot = Tuple.(findall(adj_2 .> 0))
            current_edges = Tuple.(findall(adj .> 0))

            # Remove n,n open triangles
            possible_ot = filter(x -> (x[1] != x[2]), possible_ot)

            # Check for non-closed open triangles
            open_triangles = []
            for pots in possible_ot
                if !(pots in current_edges)
                    open_triangles = [open_triangles; pots]
                end
            end

            if length(open_triangles) > 0

                # Then we can add a random edge that completes a triangle
                new_edge = sample(open_triangles)
            else

                # Then we add a new edge randomly.
                # println("no open triangles")
                open_edges = Tuple.(findall(adj .== 0))
                open_edges = filter(x -> (x[1] != x[2]), open_edges)
                new_edge = sample(open_edges)
            end

            
        else  # add an edge randomly
            
            open_edges = Tuple.(findall(adj .== 0))
            open_edges = filter(x -> (x[1] != x[2]), open_edges)
            new_edge = sample(open_edges)
            

        end

        
        adj[new_edge[1], new_edge[2]] = edges_left
        adj[new_edge[2], new_edge[1]] = edges_left
            
        

            edges_left = edges_left-1
        
    end

    return adj

end







function make_probtriangle_weighted(nNodes, p)
    ### Control how much we force triangles to from

    ## triangle graph model

    nEdges = binomial(nNodes,2)
    adj = zeros(nNodes,nNodes)

    edges_left = copy(nEdges)

    while edges_left > 0
                    
        # Flip a coin
        r = rand(1)[1]

        if r < p  # See if there's a triangle and if there is, add it. If not, add edge randomly

            # Are any triangles possible?
            adj_2 = adj^2
            adj_2[diagind(adj_2)] .= 0
            
            possible_ot = Tuple.(findall(adj_2 .> 0))
            current_edges = Tuple.(findall(adj .> 0))

            # Remove n,n open triangles
            possible_ot = filter(x -> (x[1] != x[2]), possible_ot)

            # Check for non-closed open triangles
            open_triangles = []
            for pots in possible_ot
                if !(pots in current_edges)
                    open_triangles = [open_triangles; pots]
                end
            end

            if length(open_triangles) > 0

                # Then we can add an edge that completes a triangle, weighted by time of appearance.
                ot_weights = [adj_2[ot[1], ot[2]] for ot in open_triangles]
                new_edge = sample(open_triangles, Weights(ot_weights))
            else

                # Then we add a new edge randomly.
                # println("no open triangles")
                open_edges = Tuple.(findall(adj .== 0))
                open_edges = filter(x -> (x[1] != x[2]), open_edges)
                new_edge = sample(open_edges)
            end

            
        else  # add an edge randomly
            
            open_edges = Tuple.(findall(adj .== 0))
            open_edges = filter(x -> (x[1] != x[2]), open_edges)
            new_edge = sample(open_edges)
            

        end

        
        adj[new_edge[1], new_edge[2]] = edges_left
        adj[new_edge[2], new_edge[1]] = edges_left
            
        

            edges_left = edges_left-1
        
    end

    return adj

end