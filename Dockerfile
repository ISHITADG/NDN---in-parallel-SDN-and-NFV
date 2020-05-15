FROM ubuntu:18.04

# Parse command line arguments (versions)
ARG VERSION_CXX=master
ARG VERSION_NFD=master

RUN apt-get update && \
    apt-get install -y build-essential dpkg-dev git libboost-all-dev libpcap-dev libsqlite3-dev libssl-dev pkg-config && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:named-data/ppa -y && \
    apt-get update && \
    apt install -y build-essential libboost-all-dev libssl-dev libsqlite3-dev pkg-config python-minimal && \
    apt install -y doxygen graphviz python3-pip && \
    pip3 install sphinx sphinxcontrib-doxylink
    

#install ndn-cxx
RUN git clone https://github.com/named-data/ndn-cxx.git \
    && cd ndn-cxx \
    && CXXFLAGS="-std=c++14" ./waf configure \
    && ./waf \
    && ./waf install \
    && cd .. \
    && rm -Rf ndn-cxx \
    && ldconfig

# install NFD & other ndn tools
RUN sudo apt install -y nfd \
    && cp /usr/local/etc/ndn/nfd.conf.sample /usr/local/etc/ndn/nfd.conf \
    && apt-get install -y ndn-cxx-dev \
    && ndnsec-keygen /`whoami` | ndnsec-install-cert - \
    && mkdir -p /usr/local/etc/ndn/keys \
    && ndnsec-cert-dump -i /`whoami` > default.ndncert \
    && mv default.ndncert /usr/local/etc/ndn/keys/default.ndncert \
    && apt-get install -y ndn-tools 


RUN mkdir /share \
    && mkdir /logs

# cleanup
RUN apt autoremove \
    && apt-get remove -y git build-essential python pkg-config


EXPOSE 6363/tcp
EXPOSE 6363/udp

ENV CONFIG=/usr/local/etc/ndn/nfd.conf
ENV LOG_FILE=/logs/nfd.log


# install Astreamer
RUN apt-get install wget \
    && wget -L https://github.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/blob/master/client.zip?raw=true \
    && mv client.zip\?raw\=true client.zip \
    && apt-get install unzip \
    && unzip client.zip

RUN apt-get install git \
    && git clone --recursive https://github.com/pari685/AStream.git \
    && cd AStream/dist \
    && rm -rf client \
    && mv ../../client/ . \
    && cd ../../
    

# install cmake & ndnperf-client app
RUN git clone https://github.com/Kanemochi/ndnperf.git \
    && wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz \
    && tar -xzvf cmake-3.12.2.tar.gz \
    && cd cmake-3.12.2 \
    && ./bootstrap \
    && make -j4 \
    && make install \
    && cd .. \
    && wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/client.cpp \
    && mv client.cpp ndnperf/c++/client/ \
    && cd ndnperf/c++/client \
    && cmake . && make 
    
# install iperf3
RUN git clone https://github.com/esnet/iperf.git \
    && cd iperf \
    && ./configure \
    && make \
    && make install \
    && ldconfig
    
# install dependencies for Astreamer
RUN apt-get install -y tmux \
    && apt-get install -y vim \
    && apt-get install -y python-httplib2 \
    && apt-get install -y python-setuptools \
    && apt-get install -y python-pip python-dev build-essential \
    && python -m pip install numpy scipy \
    && python -m pip install sortedcontainers \
    && python -m pip install urllib3 \
    && python -m pip install requests \
    && apt-get install -y net-tools \
    && apt-get install -y iputils-ping \
    && apt-get install -y iproute2 \
    && apt-get install -y tcpdump \
    && apt-get install -y psmisc \
    && apt-get install -y sudo \
    && cd /AStream/dist/client \
    && wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_udpD.py \
    && rm dash_client.py \
    && wget -L https://github.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/blob/master/dash_client_onlympd.py

#entrypoint cmd
ENTRYPOINT ["top", "-b"]
CMD ["-c"]
