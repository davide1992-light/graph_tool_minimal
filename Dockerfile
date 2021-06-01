FROM debian:buster-slim
#workdirectory
ARG workdir=/app

#NJOBS is the number of cores that make will employ during the compilation of graph-tool 
#WARNING graph-tool compilation needs a lot of memory, so keep NJOBS low
ARG NJOBS=1

WORKDIR $workdir 
#list of python3 libraries needed to make graph-tool work
COPY graph_tool_requirements.txt $workdir

#install compile and build essentials 
RUN apt-get update 
RUN apt-get install g++ make pkg-config -y && \
    apt-get install git -y && \ 
    apt-get install autoconf libtool -y 

    
#c++ libraries required by graph-toool
#We install boost libraries; libcgal and libexpat, and finally pip3
RUN apt-get install libboost-dev libboost-graph-dev libboost-iostreams-dev libboost-python-dev libboost-context-dev libboost-coroutine-dev libboost-regex-dev -y  && \ 
    apt-get install libcgal-dev libexpat-dev                                                                                                                  -y && \
    apt-get install python3-pip -y

#Install google's sparsehash library. NOTE For some reason sudo apt install libsparsehash-dev does not result in a successfull installation
RUN git clone https://github.com/sparsehash/sparsehash.git && \
    cd sparsehash                                          && \ 
    ./configure                                            && \
    make -j$NJOB                                           && \
    make install                                           && \
    cd $workdir                                            && \
    rm -r sparsehash

#Install python3 libraries required by graph-toool (namely numpy and scipy)
RUN pip3 install -r graph_tool_requirements.txt

#Install graph-tool.
#NOTE we use ./configure --disable-cairo because we are not interested in the visualization library.
RUN git clone https://git.skewed.de/count0/graph-tool.git && \
    cd graph-tool                                         && \
    ./autogen.sh                                          && \ 
    ./configure --disable-cairo                           && \
    make -j$NJOBS                                         && \
    make install                                          && \
    cd $workdir                                           && \
    rm -r graph-tool






