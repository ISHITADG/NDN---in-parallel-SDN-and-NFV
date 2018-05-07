#!/bin/bash
#install all NDN dependencies and tools
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:named-data/ppa
sudo apt-get update
sudo apt-get install nfd
sudo apt-get install ndn-cxx
sudo apt-get install ndn-cxx-dev
sudo apt-get install ndn-tools
nfd-start
#install ndnperf
git clone https://github.com/Kanemochi/ndnperf.git
cd ndnperf/c++/server/
g++ -o ndnperfserver server.cpp -std=c++11 -O2 -lndn-cxx -lboost_system -lboost_filesystem -lboost_thread -lpthread
echo done
