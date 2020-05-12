#!/bin/bash
#install all NDN dependencies and tools
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:named-data/ppa -y
sudo apt-get update
sudo apt install -y build-essential libboost-all-dev libssl-dev libsqlite3-dev pkg-config python-minimal
sudo apt install -y doxygen graphviz python3-pip
sudo pip3 install sphinx sphinxcontrib-doxylink

#install ndn-cxx
git clone https://github.com/named-data/ndn-cxx.git
cd ndn-cxx/
CXXFLAGS="-std=c++14" ./waf configure
./waf
sudo ./waf install
cd ..;

#install nfd
sudo add-apt-repository ppa:named-data/ppa
sudo apt update
sudo apt install -y nfd
sudo cp /usr/local/etc/ndn/nfd.conf.sample /usr/local/etc/ndn/nfd.conf
sudo apt-get install -y ndn-cxx-dev
#adding security element
sudo ndnsec-keygen /`whoami` | ndnsec-install-cert -
sudo mkdir -p /usr/local/etc/ndn/keys
sudo ndnsec-cert-dump -i /`whoami` > default.ndncert
sudo mv default.ndncert /usr/local/etc/ndn/keys/default.ndncert

#install cmake
version=3.12;
build=2;
mkdir temp;
cd temp;
wget https://cmake.org/files/v$version/cmake-$version.$build.tar.gz;
tar -xzvf cmake-$version.$build.tar.gz;
cd cmake-$version.$build/;
./bootstrap;
make -j4;
sudo make install;
cmake --version;
cd ../..;

#install ndnperf & tools
sudo apt-get install -y ndn-tools
git clone https://github.com/Kanemochi/ndnperf.git
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/client.cpp
mv client.cpp ndnperf/c++/client/
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/CMakeLists.txt
mv CMakeLists.txt ndnperf/c++/client/
cd ndnperf/c++/client/

cmake . && make

#other systemctl updates
sudo cp nfd.service /etc/systemd/system
sudo systemctl daemon-reload
sudo mkdir -p /usr/local/var/log/ndn
sudo chown -R ndn:ndn /usr/local/var/log/ndn
sudo sh -c ' \
  mkdir -p /usr/local/var/lib/ndn/nfd/.ndn; \
  export HOME=/usr/local/var/lib/ndn/nfd; \
  ndnsec-keygen /localhost/daemons/nfd | ndnsec-install-cert -; \
'
sudo sh -c '\
  mkdir -p /usr/local/etc/ndn/certs || true; \
  export HOME=/usr/local/var/lib/ndn/nfd; \
  ndnsec-dump-certificate -i /localhost/daemons/nfd > \
    /usr/local/etc/ndn/certs/localhost_daemons_nfd.ndncert; \
'
echo done
