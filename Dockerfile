FROM jupyter/datascience-notebook:7a0c7325e470

RUN pip install iisignature
RUN pip install kmapper
RUN pip install sklearn

RUN julia -e 'using Pkg; Pkg.add("HDF5")'
RUN julia -e 'using Pkg; Pkg.add("JLD")'
RUN julia -e 'using Pkg; Pkg.add("Plotly")'
RUN julia -e 'using Pkg; Pkg.add("Eirene")'
RUN julia -e 'using Pkg; Pkg.add("Combinatorics")'
RUN julia -e 'using Pkg; Pkg.add("SparseArrays")'
RUN julia -e 'using Pkg; Pkg.add("Plots")'
RUN julia -e 'using Pkg; Pkg.add("MAT")'
RUN julia -e 'using Pkg; Pkg.add("Statistics")'
RUN julia -e 'using Pkg; Pkg.add("LightGraphs")'
RUN julia -e 'using Pkg; Pkg.add("DataFrames")'
RUN julia -e 'using Pkg; Pkg.add("PyCall")'
RUN julia -e 'using Pkg; Pkg.add("LinearAlgebra")'
RUN julia -e 'using Pkg; Pkg.add("GraphPlot")'
RUN julia -e 'using Pkg; Pkg.add("Distances")'
RUN julia -e 'using Pkg; Pkg.add("StatsBase")'
RUN julia -e 'using Pkg; Pkg.add("Distributions")'
RUN julia -e 'using Pkg; Pkg.add("Random")'
RUN julia -e 'using Pkg; Pkg.add("CSV")'
RUN julia -e 'using Pkg; Pkg.add("ColorSchemes")'
RUN julia -e 'using Pkg; Pkg.add("StatsPlots")'



USER root
RUN apt-get update && apt-get install -y \
  libz-dev \
  libqt4-dev
USER jovyan


COPY code .


EXPOSE 8888
