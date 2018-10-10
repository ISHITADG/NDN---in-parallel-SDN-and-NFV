#!/bin/bash
#install all NDN dependencies and tools
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:named-data/ppa
sudo apt-get update
sudo apt-get install -y nfd
sudo apt-get install -y ndn-cxx
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
g++ -o ndnperfserver server.cpp -std=c++11 -O2 -lndn-cxx -lboost_system -lboost_filesystem -lboost_thread -lpthread



echo done
