FROM ubuntu:18.04

# Parse command line arguments (versions)
ARG VERSION_CXX=master
ARG VERSION_NFD=master

RUN apt-get update && \
    apt-get install -y build-essential dpkg-dev git libboost-all-dev libpcap-dev libsqlite3-dev libssl-dev pkg-config

#install ndn-cxx
RUN git clone https://github.com/named-data/ndn-cxx.git \
    && cd ndn-cxx \
    && git checkout $VERSION_CXX \
    && ./waf configure \
    && ./waf \
    && ./waf install \
    && cd .. \
    && rm -Rf ndn-cxx \
    && ldconfig

# install NFD
RUN git clone --recursive https://github.com/named-data/NFD \
    && cd NFD \
    && git checkout $VERSION_NFD \
    && ./waf configure \
    && ./waf \
    && ./waf install \
    && cd .. \
    && rm -Rf NFD

# install ndn-tools
RUN git clone --recursive https://github.com/named-data/ndn-tools.git \
    && cd ndn-tools \
    && git checkout 48cb0b6f2eb2594064432692a56a4ccee4085d20 \
    && ./waf configure \
    && ./waf \
    && ./waf install \
    && cd .. \
    && rm -Rf ndn-tools

# initial configuration
RUN cp /usr/local/etc/ndn/nfd.conf.sample /usr/local/etc/ndn/nfd.conf \
    && ndnsec-keygen /`whoami` | ndnsec-install-cert - \
    && mkdir -p /usr/local/etc/ndn/keys \
    && ndnsec-cert-dump -i /`whoami` > default.ndncert \
    && mv default.ndncert /usr/local/etc/ndn/keys/default.ndncert

RUN mkdir /share \
    && mkdir /logs

# cleanup
RUN apt autoremove \
    && apt-get remove -y git build-essential python pkg-config


EXPOSE 6363/tcp
EXPOSE 6363/udp

ENV CONFIG=/usr/local/etc/ndn/nfd.conf
ENV LOG_FILE=/logs/nfd.log

CMD /usr/local/bin/nfd -c $CONFIG > $LOG_FILE 2>&1

CMD /usr/local/bin/nfd -c $CONFIG > $LOG_FILE 2>&1

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
    && mv ../../client/ .
    

# install cmake & ndnperf-client app & net-tools
RUN git clone https://github.com/Kanemochi/ndnperf.git \
    && wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz \
    && tar -xzvf cmake-3.12.2.tar.gz \
    && cd cmake-3.12.2 \
    && ./bootstrap \
    && make -j4 \
    && make install \
    && cd .. \
    && cd ndnperf/c++ \
    && wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/client.cpp \
    && cd client \
    && rm client.cpp \
    && mv ../client.cpp . \
    && cmake . && make \
    && apt-get install net-tools \
    && apt-get install iputils-ping \
    && apt-get install iproute2
