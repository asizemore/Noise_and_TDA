# Code for "Variability in higher order structure of noise added to weighted networks".
### Blevins, Kim, and Bassett, arxiv 2021

-----
### Links
- paper on arxiv
- supplementary interactive visualizations [site](https://asizemore.github.io/noise_and_tda_supplement/)
- persistent homology software used: [Eirene](https://github.com/Eetion/Eirene.jl)

----
This repository contains all the code necessary to reproduce the results found in the "Variability in higher order structure of noise added to weighted networks" paper. 

Given the computational intensity of some of the code, the graph generation and persistent homology calculations were performed using an available cluster. Still, the entire pipeline can be run on a local computer by reducing the number of nodes in the graphs and the maximum persistent homology dimension.

## Pipeline
![Code pipeline overview](./images/code_structure-01.png)

*Step 0: Setting up the container*

Included with the repository is all needed files to create a docker container in which to run this project. It is not necessary to run the code within the container, but it is highly recommended. 

To get started, download [Docker](https://www.docker.com/products/docker-desktop) and ensure it is running. In the terminal, navigate to this directory and run `make build` to build the container, and then `docker run -it --rm -p 8888:8888 -v $(pwd):/home/jovyan/ noise_detection:deploy-01` to run the container. 

*Step 1: Prepare configuration file*

Each step of the process expects an input configuration file named with the date (see examples in the 'configs' folder). This .json file contains all the parameters needed for the calculations (number of nodes, maximum persistent homology dimension, etc.) and model networks. 


*Step 2: Generate network models - create_graphs.jl*

Parameters from config file: `NREPS`, `NNODES`, `DATE_STRING`, `NAMETAG_creategraphs`, `graph_models`, `HOMEDIR`, `save_dir_graphs`

Running this script will generate `NREPS` graphs for every model listed in `graph_models` with `create_flag` set to "create". See graph_models.jl for the list of network models available. All graphs will have `NNODES` nodes and parameters as listed in the configuration file. Graphs are saved as an `NNODES` x `NNODES` x `NREPS` array in a .jld file with name and location determined by `NAMETAG_creategraphs` and `save_dir_graphs`.








