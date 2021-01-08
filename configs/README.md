# Description of configuration files

Parameters:
- `NNODES`: Number of nodes in the final networks
- `NREPS`: Number of replicates. For example, if `NREPS=3` we will generate three graphs from each graph model.
- DATE_STRING: Date
- SAVEDATA: Boolean dictating whether data/results should be written to files.
- NAMETAG_creategraphs: Ending to filenames that store created graphs. Used in `create_graphs.jl`.
- HOMEDIR: The home directory.
- save_dir_graphs: Designate the directory in which to save graph models. Used in `create_graphs.jl`.
- save_dir_thresh: Designate directory in which to save thresholded graphs. Used in `threshold_graphs.jl`.
- read_dir_thresh: Designate directory from which to read graphs for thresholding. Used in `threshold_graphs.jl`. This script will look for any files within the `read_dir_thresh` location that have the `_graphs.jld` tag.
- read_dir_overlap: Designate directory from which to read 