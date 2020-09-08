# ADD file:4e6b5d9ca371eb881c581574b8dc4f5391eff2872db364af0f8d9804e4890098 in / 
# /bin/sh -c [ -z "$(apt-get indextargets)" ]
# /bin/sh -c set -xe 		&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d 	&& echo 'exit 101' >> /usr/sbin/policy-rc.d 	&& chmod +x /usr/sbin/policy-rc.d 		&& dpkg-divert --local --rename --add /sbin/initctl 	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl 	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl 		&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup 		&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean 	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean 	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean 		&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages 		&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes 		&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
# /bin/sh -c mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
#  CMD ["/bin/bash"]
#  LABEL maintainer=JupyterProject<jupyter@googlegroups.com>
#  ARG NB_USER=jovyan
#  ARG NB_UID=1000
#  ARG NB_GID=100
#  USER root
#  ENV DEBIAN_FRONTEND=noninteractive
# |3 NB_GID=100 NB_UID=1000 NB_USER=jovyan /bin/sh -c apt-get update  && apt-get install -yq --no-install-recommends     wget     bzip2     ca-certificates     sudo     locales     fonts-liberation     run-one  && apt-get clean && rm -rf /var/lib/apt/lists/*
# |3 NB_GID=100 NB_UID=1000 NB_USER=jovyan /bin/sh -c echo "en_US.UTF-8 UTF-8" > /etc/locale.gen &&     locale-gen
#  ENV CONDA_DIR=/opt/conda SHELL=/bin/bash NB_USER=jovyan NB_UID=1000 NB_GID=100 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
#  ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin HOME=/home/jovyan
# ADD file:2407375a36b13fb421cfc19e79bb173b917242379d7aa88e759005477f3a0de2 in /usr/local/bin/fix-permissions 
# /bin/sh -c chmod a+rx /usr/local/bin/fix-permissions
# /bin/sh -c sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc
# /bin/sh -c echo "auth requisite pam_deny.so" >> /etc/pam.d/su &&     sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers &&     sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers &&     useradd -m -s /bin/bash -N -u $NB_UID $NB_USER &&     mkdir -p $CONDA_DIR &&     chown $NB_USER:$NB_GID $CONDA_DIR &&     chmod g+w /etc/passwd &&     fix-permissions $HOME &&     fix-permissions "$(dirname $CONDA_DIR)"
#  USER 1000
# WORKDIR /home/jovyan
#  ARG PYTHON_VERSION=default
# |1 PYTHON_VERSION=default /bin/sh -c mkdir /home/$NB_USER/work &&     fix-permissions /home/$NB_USER
#  ENV MINICONDA_VERSION=4.7.10 MINICONDA_MD5=1c945f2b3335c7b2b15130b1b2dc5cf4 CONDA_VERSION=4.7.12
# |1 PYTHON_VERSION=default /bin/sh -c cd /tmp &&     wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh &&     echo "${MINICONDA_MD5} *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - &&     /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR &&     rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh &&     echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned &&     $CONDA_DIR/bin/conda config --system --prepend channels conda-forge &&     $CONDA_DIR/bin/conda config --system --set auto_update_conda false &&     $CONDA_DIR/bin/conda config --system --set show_channel_urls true &&     if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi &&     conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned &&     $CONDA_DIR/bin/conda install --quiet --yes conda &&     $CONDA_DIR/bin/conda update --all --quiet --yes &&     conda clean --all -f -y &&     rm -rf /home/$NB_USER/.cache/yarn &&     fix-permissions $CONDA_DIR &&     fix-permissions /home/$NB_USER
# |1 PYTHON_VERSION=default /bin/sh -c conda install --quiet --yes 'tini=0.18.0' &&     conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned &&     conda clean --all -f -y &&     fix-permissions $CONDA_DIR &&     fix-permissions /home/$NB_USER
# |1 PYTHON_VERSION=default /bin/sh -c conda install --quiet --yes     'notebook=6.0.0'     'jupyterhub=1.0.0'     'jupyterlab=1.2.1' &&     conda clean --all -f -y &&     npm cache clean --force &&     jupyter notebook --generate-config &&     rm -rf $CONDA_DIR/share/jupyter/lab/staging &&     rm -rf /home/$NB_USER/.cache/yarn &&     fix-permissions $CONDA_DIR &&     fix-permissions /home/$NB_USER
#  EXPOSE 8888
#  ENTRYPOINT ["tini" "-g" "--"]
#  CMD ["start-notebook.sh"]
#  COPY file:be20131ba97563898c30998c19104b0d58d61a982ea5555a2002b0c2f0b49668 in /usr/local/bin/ 
# COPY file:b2c3f5a0f1eb5ccb09652a170a2345d2c65ff31f325fb29250fc500957117659 in /usr/local/bin/ 
# COPY file:f18466c43c93e954cf68e631cbbe61aba2ec666f0dd9a113f97404789f539808 in /usr/local/bin/ 
# COPY file:cd827a3a9853bdea9decd0b6548b957cbe9821532361805d99dee359cfbbd1c0 in /etc/jupyter/ 
#  USER root
# |1 PYTHON_VERSION=default /bin/sh -c fix-permissions /etc/jupyter/
#  USER 1000
#  LABEL maintainer=JupyterProject<jupyter@googlegroups.com>
#  USER root
# /bin/sh -c apt-get update && apt-get install -yq --no-install-recommends     build-essential     emacs     git     inkscape     jed     libsm6     libxext-dev     libxrender1     lmodern     netcat     pandoc     python-dev     texlive-fonts-extra     texlive-fonts-recommended     texlive-generic-recommended     texlive-latex-base     texlive-latex-extra     texlive-xetex     tzdata     unzip     nano     && apt-get clean && rm -rf /var/lib/apt/lists/*
#  USER 1000
#  LABEL maintainer=JupyterProject<jupyter@googlegroups.com>
#  USER root
# /bin/sh -c apt-get update &&     apt-get install -y --no-install-recommends ffmpeg &&     rm -rf /var/lib/apt/lists/*
#  USER 1000
# /bin/sh -c conda install --quiet --yes     'beautifulsoup4=4.8.*'     'conda-forge::blas=*=openblas'     'bokeh=1.3*'     'cloudpickle=1.2*'     'cython=0.29*'     'dask=2.2.*'     'dill=0.3*'     'h5py=2.9*'     'hdf5=1.10*'     'ipywidgets=7.5*'     'matplotlib-base=3.1.*'     'numba=0.45*'     'numexpr=2.6*'     'pandas=0.25*'     'patsy=0.5*'     'protobuf=3.9.*'     'scikit-image=0.15*'     'scikit-learn=0.21*'     'scipy=1.3*'     'seaborn=0.9*'     'sqlalchemy=1.3*'     'statsmodels=0.10*'     'sympy=1.4*'     'vincent=0.4.*'     'xlrd'     &&     conda clean --all -f -y &&     jupyter nbextension enable --py widgetsnbextension --sys-prefix &&     jupyter labextension install @jupyter-widgets/jupyterlab-manager@^1.0.1 --no-build &&     jupyter labextension install jupyterlab_bokeh@1.0.0 --no-build &&     jupyter lab build &&     npm cache clean --force &&     rm -rf $CONDA_DIR/share/jupyter/lab/staging &&     rm -rf /home/$NB_USER/.cache/yarn &&     rm -rf /home/$NB_USER/.node-gyp &&     fix-permissions $CONDA_DIR &&     fix-permissions /home/$NB_USER
# /bin/sh -c cd /tmp &&     git clone https://github.com/PAIR-code/facets.git &&     cd facets &&     jupyter nbextension install facets-dist/ --sys-prefix &&     cd &&     rm -rf /tmp/facets &&     fix-permissions $CONDA_DIR &&     fix-permissions /home/$NB_USER
#  ENV XDG_CACHE_HOME=/home/jovyan/.cache/
# /bin/sh -c MPLBACKEND=Agg python -c "import matplotlib.pyplot" &&     fix-permissions /home/$NB_USER
#  USER 1000
#  LABEL maintainer=JupyterProject<jupyter@googlegroups.com>
#  ARG TEST_ONLY_BUILD
#  USER root
# /bin/sh -c apt-get update &&     apt-get install -y --no-install-recommends     fonts-dejavu     gfortran     gcc &&     rm -rf /var/lib/apt/lists/*
#  ENV JULIA_DEPOT_PATH=/opt/julia
#  ENV JULIA_PKGDIR=/opt/julia
#  ENV JULIA_VERSION=1.2.0
# /bin/sh -c mkdir /opt/julia-${JULIA_VERSION} &&     cd /tmp &&     wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz &&     echo "926ced5dec5d726ed0d2919e849ff084a320882fb67ab048385849f9483afc47 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - &&     tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 &&     rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
# /bin/sh -c ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia
# /bin/sh -c mkdir /etc/julia &&     echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl &&     mkdir $JULIA_PKGDIR &&     chown $NB_USER $JULIA_PKGDIR &&     fix-permissions $JULIA_PKGDIR
#  USER 1000
# /bin/sh -c conda install --quiet --yes     'r-base=3.6.1'     'r-caret=6.0*'     'r-crayon=1.3*'     'r-devtools=2.1*'     'r-forecast=8.7*'     'r-hexbin=1.27*'     'r-htmltools=0.3*'     'r-htmlwidgets=1.3*'     'r-irkernel=1.0*'     'r-nycflights13=1.0*'     'r-plyr=1.8*'     'r-randomforest=4.6*'     'r-rcurl=1.95*'     'r-reshape2=1.4*'     'r-rmarkdown=1.14*'     'r-rsqlite=2.1*'     'r-shiny=1.3*'     'r-sparklyr=1.0*'     'r-tidyverse=1.2*'     'rpy2=2.9*'     &&     conda clean --all -f -y &&     fix-permissions $CONDA_DIR &&     fix-permissions /home/$NB_USER
# /bin/sh -c julia -e 'import Pkg; Pkg.update()' &&     (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")') &&     julia -e "using Pkg; pkg\"add IJulia\"; pkg\"precompile\"" &&     mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ &&     chmod -R go+rx $CONDA_DIR/share/jupyter &&     rm -rf $HOME/.local &&     fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter









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
RUN julia -e 'using Pkg; Pkg.add("Plotly"); Base.compilecache(Base.identify_package("Plotly"))'
RUN julia -e 'using Pkg; Pkg.add("Eirene"); Base.compilecache(Base.identify_package("Eirene"))'
RUN julia -e 'using Pkg; Pkg.add("Combinatorics"); Base.compilecache(Base.identify_package("Combinatorics"))'
# RUN julia -e 'using Pkg; Pkg.add("SparseArrays")'
RUN julia -e 'using Pkg; Pkg.add("Plots"); Base.compilecache(Base.identify_package("Plots"))'
RUN julia -e 'using Pkg; Pkg.add("MAT"); Base.compilecache(Base.identify_package("MAT"))'
# RUN julia -e 'using Pkg; Pkg.add("Statistics")'
RUN julia -e 'using Pkg; Pkg.add("LightGraphs"); Base.compilecache(Base.identify_package("LightGraphs"))'
RUN julia -e 'using Pkg; Pkg.add("DataFrames"); Base.compilecache(Base.identify_package("DataFrames"))'
RUN julia -e 'using Pkg; Pkg.add("PyCall"); Base.compilecache(Base.identify_package("PyCall"))'
# RUN julia -e 'using Pkg; Pkg.add("LinearAlgebra")'
RUN julia -e 'using Pkg; Pkg.add("GraphPlot"); Base.compilecache(Base.identify_package("GraphPlot"))'
RUN julia -e 'using Pkg; Pkg.add("Distances"); Base.compilecache(Base.identify_package("Distances"))'
RUN julia -e 'using Pkg; Pkg.add("StatsBase"); Base.compilecache(Base.identify_package("StatsBase"))'
RUN julia -e 'using Pkg; Pkg.add("Distributions"); Base.compilecache(Base.identify_package("Distributions"))'
# RUN julia -e 'using Pkg; Pkg.add("Random")'
RUN julia -e 'using Pkg; Pkg.add("CSV"); Base.compilecache(Base.identify_package("CSV"))'
RUN julia -e 'using Pkg; Pkg.add("ColorSchemes"); Base.compilecache(Base.identify_package("ColorSchemes"))'
RUN julia -e 'using Pkg; Pkg.add("StatsPlots"); Base.compilecache(Base.identify_package("StatsPlots"))'
RUN julia -e 'using Pkg; Pkg.add("JSON"); Base.compilecache(Base.identify_package("JSON"))'
# RUN julia -e 'using Pkg; for pkg in collect(keys(Pkg.installed())) Base.compilecache(Base.identify_package(pkg)) end'
# RUN julia -e 'using Pkg; Pkg.add("SimpleContainerGenerator")'
# RUN julia -e 'using Statistics'
# RUN julia -e 'using Random'
# RUN julia -e 'using LinearAlgebra'
# RUN julia -e 'using JSON'
# RUN julia -e 'include("graph_models.jl")'
# RUN julia -e 'include("helper_functions.jl")'

RUN /bin/bash -c 'chmod -R 755 /opt/julia'



COPY code .


EXPOSE 8888
