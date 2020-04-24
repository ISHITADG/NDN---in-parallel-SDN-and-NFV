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

#install ndnperf & tools
sudo apt-get install -y ndn-tools
nfd-start
git clone https://github.com/Kanemochi/ndnperf.git
cd ndnperf/c++/server/
cmake . && make

echo done
