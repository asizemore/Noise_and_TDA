
FROM jupyter/datascience-notebook:7a0c7325e470

USER root
RUN apt-get update && apt-get install -y \
  libz-dev \
  libqt4-dev

# RUN pip install iisignature
# RUN pip install kmapper
# RUN pip install sklearn

RUN julia -e 'using Pkg; Pkg.add("HDF5"); Base.compilecache(Base.identify_package("HDF5"))'
RUN julia -e 'using Pkg; Pkg.add("JLD"); Base.compilecache(Base.identify_package("JLD"))'
# RUN julia -e 'using Pkg; Pkg.add("Plotly"); Base.compilecache(Base.identify_package("Plotly"))'
RUN julia -e 'using Pkg; Pkg.add("Eirene"); Base.compilecache(Base.identify_package("Eirene"))'
RUN julia -e 'using Pkg; Pkg.add("Combinatorics"); Base.compilecache(Base.identify_package("Combinatorics"))'
# RUN julia -e 'using Pkg; Pkg.add("SparseArrays")'
RUN julia -e 'using Pkg; Pkg.add("Plots"); Base.compilecache(Base.identify_package("Plots"))'
RUN julia -e 'using Pkg; Pkg.add("MAT"); Base.compilecache(Base.identify_package("MAT"))'
# RUN julia -e 'using Pkg; Pkg.add("Statistics")'
# RUN julia -e 'using Pkg; Pkg.add("LightGraphs"); Base.compilecache(Base.identify_package("LightGraphs"))'
RUN julia -e 'using Pkg; Pkg.add("DataFrames"); Base.compilecache(Base.identify_package("DataFrames"))'
RUN julia -e 'using Pkg; Pkg.add("PyCall"); Base.compilecache(Base.identify_package("PyCall"))'
# RUN julia -e 'using Pkg; Pkg.add("LinearAlgebra")'
# RUN julia -e "using Pkg; Pkg.update()"
# RUN julia -e 'using Pkg; Pkg.add("GraphPlot"); Base.compilecache(Base.identify_package("GraphPlot"))'
RUN julia -e 'using Pkg; Pkg.add("Distances"); Base.compilecache(Base.identify_package("Distances"))'
RUN julia -e 'using Pkg; Pkg.add("StatsBase"); Base.compilecache(Base.identify_package("StatsBase"))'
RUN julia -e 'using Pkg; Pkg.add("Distributions"); Base.compilecache(Base.identify_package("Distributions"))'
# RUN julia -e 'using Pkg; Pkg.add("Random")'
RUN julia -e 'using Pkg; Pkg.add("CSV"); Base.compilecache(Base.identify_package("CSV"))'
RUN julia -e 'using Pkg; Pkg.add("StatsPlots"); Base.compilecache(Base.identify_package("StatsPlots"))'
RUN julia -e 'using Pkg; Pkg.add("JSON"); Base.compilecache(Base.identify_package("JSON"))'
RUN julia -e 'using Pkg; Pkg.add("Eirene"); Base.compilecache(Base.identify_package("Eirene"))'
# RUN julia -e 'using Pkg; Pkg.add("ColorSchemes"); Base.compilecache(Base.identify_package("ColorSchemes"))'
# RUN julia -e 'using Pkg; for pkg in collect(keys(Pkg.installed())) Base.compilecache(Base.identify_package(pkg)) end'
# RUN julia -e 'using Pkg; Pkg.add("SimpleContainerGenerator")'
# RUN julia -e 'using Statistics'
# RUN julia -e 'using Random'
# RUN julia -e 'using LinearAlgebra'
# RUN julia -e 'using JSON'
# RUN julia -e 'include("graph_models.jl")'
# RUN julia -e 'include("helper_functions.jl")'

RUN /bin/bash -c 'chmod -R 777 /opt/julia'



COPY code .


EXPOSE 8888
