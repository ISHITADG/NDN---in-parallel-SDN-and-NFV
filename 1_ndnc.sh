#!/bin/bash

sudo apt-get -y install tmux; 
sudo apt-get -y install vim;
sudo apt-get -y install python-httplib2;
sudo apt-get -y install python-setuptools;
sudo apt-get -y install python-pip python-dev build-essential;
sudo pip install --upgrade pip;
sudo pip install numpy scipy;
sudo pip install sortedcontainers;
sudo pip install pandas;
sudo apt-get -y install python-numpy python-scipy python-matplotlib;
git clone https://github.com/esnet/iperf.git;
cd iperf;
./configure;
make;
make install;
ldconfig;
iperf3 -v;

#SETUP DOCKER AND OPENVSWITCH
cd /users/ishitadg;
sudo wget https://raw.githubusercontent.com/ISHITADG/dockerNDN/master/dockovs.sh;
bash dockovs.sh;

#SETUP NDN DOCKER
cp -r /proj/WRFHydro/ndndocker.tar .;
docker image load -i ndndocker.tar
rm ndndocker.tar;

#FOR RUNNING ON THE HOST CLIENT
#install cmake
cd /users/ishitadg;
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
# compile ndnperf client: 
cd /users/ishitadg/ndnperf/c++/client/;
cmake . && make;
#this installs Astreamer on Client host too
cd /users/ishitadg;
wget -L https://github.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/blob/master/client.zip?raw=true;
mv client.zip\?raw\=true client.zip;
sudo apt-get install unzip;
unzip client.zip;
git clone --recursive https://github.com/pari685/AStream.git;
rm client.zip;
cd AStream/dist; rm -rf client; mv ../../client/ .;
#install all scripts
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/startdockers.sh;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/setupdockers.sh;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/pingtest.sh;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnlive.sh;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnliveqoe.sh; 

echo done