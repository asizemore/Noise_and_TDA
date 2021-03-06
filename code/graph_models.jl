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


 
function make_dev_DiscreteUniform_configuration_model(nNodes::Int64,a::Int64,b::Int64)
    
    # Create a configuration model using the discrete uniform distribution between a and b.
    # Configuration based on the networkx implementation and [1] M.E.J. Newman, "The structure and function of complex networks",SIAM REVIEW 45-2, pp 167-256, 2003.
    
    # Define distribution
    d = DiscreteUniform(a,b)
    strength_sequence::Array{Int64,1} = rand(d,nNodes)
    
    adj::Array{Float32,2} = zeros(nNodes,nNodes)
    
    # Ensure sum of strength_sequence is even
    while sum(strength_sequence)%2 == 1
        strength_sequence = rand(d,nNodes)
    
    end

    println(sum(strength_sequence))

    println(maximum(strength_sequence))
    
    # Create stubs array with stubs numbered by their parent node
    stubs_array = Array{Int64,1}(undef,(sum(strength_sequence)))
    for (node,strength) in enumerate(strength_sequence)

        if node==1
            stubs_array[1:strength_sequence[node]] .= node
        else
            u = cumsum(strength_sequence[1:(node-1)])[end]+1
            v = cumsum(strength_sequence[1:node])[end]
            stubs_array[u:v] .= node
        end

    end
    # stubs_array = Array{Int32,1}(undef,(sum(strength_sequence)))
    # for (node,strength) in enumerate(strength_sequence)
    #     if node==1
    #         stubs_array[1:strength_sequence[node]] .= node
    #     else
    #         stubs_array[(cumsum(strength_sequence[1:(node-1)])+1):cumsum(strength_sequence[1:node])] .= node
    #     end

    #     # stubs_array[] = [stubs_array; node.*ones(Int8, (strength))]
    # end
    # stubs_array = [node*ones(Int8, (strength)); for (node,strength) in enumerate(strength_sequence)]

    println(size(stubs_array))
    
    # Shuffle array
    stubs_array_shuffled = Int.(shuffle(stubs_array))
    
    # Add pairs of stubs to adjacency matrix
    while !isempty(stubs_array_shuffled)
        
        node1 = pop!(stubs_array_shuffled)
        node2 = pop!(stubs_array_shuffled)
        
        # Add to adjacency matrix if node1 neq node2. If node1=node2, return to array and shuffle or break
        if node1 !== node2
    
            adj[node1, node2] = adj[node1, node2] + 1
            adj[node2, node1] = adj[node1, node2]
            
        else
        
            append!(stubs_array_shuffled, node1)
            append!(stubs_array_shuffled, node2)
    
            # If there are at least two non-identical nodes left, shuffle array. If not, break the loop.
            # This could result in excatly one node having a strength less than that assigned at strength_sequence
            (length(unique(stubs_array_shuffled))>1) ? shuffle!(stubs_array_shuffled) : break 
    
        end
            
    
    end
    
    # Ensure diagonal is 0
    adj[diagind(adj)].=0
    
    # Check for symmetry
    tf = is_symmetric(adj)
    
    return adj
end





function make_dev_Geometric_configuration_model(nNodes,p,scale_factor)
    
    # Create a configuration model using the Geometric distribution with parameter p. To get enough edges,
    # scale by scale_factor
    # Configuration based on the networkx implementation and [1] M.E.J. Newman, "The structure and function of complex networks",SIAM REVIEW 45-2, pp 167-256, 2003.
    
    
    # Define distribution
    d = Geometric(p)
    strength_sequence = scale_factor*rand(d,nNodes)
    
    adj = zeros(nNodes,nNodes)
    
    # Ensure sum of strength_sequence is even
    while sum(strength_sequence)%2 == 1
        strength_sequence = rand(d,nNodes)
    
    end
    
    # Create stubs array with stubs numbered by their parent node
    stubs_array = []
    for (node,strength) in enumerate(strength_sequence)
        stubs_array = [stubs_array; node.*ones((strength))]
    end
    
    # Shuffle array
    stubs_array_shuffled = Int.(shuffle(stubs_array))
    
    # Add pairs of stubs to adjacency matrix
    while !isempty(stubs_array_shuffled)
        
        node1 = pop!(stubs_array_shuffled)
        node2 = pop!(stubs_array_shuffled)
        
        # Add to adjacency matrix if node1 neq node2. If node1=node2, return to array and shuffle or break
        if node1 !== node2
    
            adj[node1, node2] = adj[node1, node2] + 1
            adj[node2, node1] = adj[node1, node2]
            
        else
        
            append!(stubs_array_shuffled, node1)
            append!(stubs_array_shuffled, node2)
    
            # If there are at least two non-identical nodes left, shuffle array. If not, break the loop.
            # This could result in excatly one node having a strength less than that assigned at strength_sequence
            (length(unique(stubs_array_shuffled))>1) ? shuffle!(stubs_array_shuffled) : break 
    
        end
            
    
    end
    
    # Ensure diagonal is 0
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



function make_clique(nNodes)

    edges_total = binomial(nNodes,2)
    adj = zeros(nNodes,nNodes)

    edges_left = edges_total
    for i in 2:nNodes
        for j in 1:(i-1)
            adj[i,j] = edges_left
            edges_left = edges_left -1
        end
    end

    adj = adj+transpose(adj)

    # Check for symmetry
    tf = is_symmetric(adj)

    return adj

end


function make_cliques(nNodes,m)


    adj = make_clique(nNodes)

    for r in 2:m

        r_clique_adj = make_clique(nNodes)
        perm = randperm(nNodes)
        adj = adj .+ r_clique_adj[perm,perm]


    end


    # Check for symmetry
    tf = is_symmetric(adj)

    return adj

end


function make_kclique(nNodes, k)
    
    
    adj = zeros(nNodes,nNodes)

    zero_edges_left = sum(triu_elements(adj,1).==0)

    while zero_edges_left >200
        
        # Pick random k clique and add
        clique_nodes = sample(collect(1:nNodes),k,replace=false)
        adj[clique_nodes,clique_nodes] .= adj[clique_nodes,clique_nodes] .+ 1
        
        zero_edges_left = sum(triu_elements(adj,1).==0)

    end

    return adj
end


function make_kstar(nNodes, k)

    adj = zeros(nNodes,nNodes)

    zero_edges_left = sum(triu_elements(adj,1).==0)

    while zero_edges_left >200
        
        # Pick random k star and add
        star_center = sample(collect(1:nNodes),1,replace=false)
        star_nodes = sample(deleteat!(collect(1:nNodes),star_center),k,replace=false)
        adj[star_center,star_nodes] .= adj[star_center,star_nodes] .+ 1
        adj[star_nodes,star_center] .= adj[star_nodes,star_center] .+ 1
        
        zero_edges_left = sum(triu_elements(adj,1).==0)

    end

    return adj
end

function make_star(nNodes)

    nEdges = binomial(nNodes,2)
    adj = zeros(nNodes,nNodes)

    for i=1:nNodes
        for j = (i+1):nNodes
            adj[i,j] = nEdges
            adj[j,i] = nEdges
            nEdges = nEdges-1
        end
    end

    return adj

end


function make_stick_lattice(nNodes)

    adj = zeros(nNodes,nNodes)

    for i=1:nNodes
        for j = (i+1):nNodes
            adj[i,j] = 1 ./abs(i-j)
            adj[j,i] = 1 ./abs(i-j)
        end
    end

    return adj
        
end




