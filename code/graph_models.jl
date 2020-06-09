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
        v = ones(1,(nNodes-1)) ./ [transpose(collect(1:floor(nNodes/2))) transpose(reverse(collect(1:floor(nNodes/2))))]
        v = [0 v]
        adj = deepcopy(v)
        for n in 1:(nNodes-1)
            adj = [adj; zeros(1,n) transpose(v[1,1:(nNodes-n)])]
        end
        adj = adj .+ (1/(nNodes^4))*rand(nNodes,nNodes)
        adj = adj+transpose(adj)
        adj[diagind(adj)].=0
        
        
    end
    
    return adj
end


function make_cosine_geometric(nNodes,dims)
    
    # Generate random coordinates in [0,1)^dims
    randomCoordinates = rand(dims,nNodes)
    
    # Compute pairwise distances between nodes (points in [0,1)^dims)
    adj = pairwise(CosineDist(), randomCoordinates, dims = 2)
    
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
    adj = adj+adj'
    
    # Add noise
    adj = adj .+ (1/(nNodes^4))*rand(nNodes,nNodes)
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
    adj = adj+adj'
    
    # Add noise
    adj = adj .+ (1/(nNodes^4))*rand(nNodes,nNodes)
    adj = adj+transpose(adj)
    adj[diagind(adj)].=0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end
