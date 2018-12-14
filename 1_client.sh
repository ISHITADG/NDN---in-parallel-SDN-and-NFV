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


#SETUP DOCKER AND OPENVSWITCH
sudo wget https://raw.githubusercontent.com/ISHITADG/dockerNDN/master/dockovs.sh
bash dockovs.sh

#SETUP NDN DOCKER

#download Dockerfile(includes downloading Astreamer and Bhushan's client code)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/Dockerfile;

#build docker ndn docker type
sudo docker build -t ndndock --build-arg VERSION_CXX=ndn-cxx-0.6.1 --build-arg VERSION_NFD=NFD-0.6.1 .

#Run NDN docker
docker run -d --rm --name ndn1 -p 6364:6363 -p 6365:6363/udp ndndock
docker run -d --rm --name ndn2 -p 6366:6363 -p 6367:6363/udp ndndock
docker run -d --rm --name ndn3 -p 6368:6363 -p 6369:6363/udp ndndock
docker run -d --rm --name ndn4 -p 6370:6363 -p 6371:6363/udp ndndock
docker run -d --rm --name ndn5 -p 6372:6363 -p 6373:6363/udp ndndock
docker run -d --rm --name ndn6 -p 6374:6363 -p 6375:6363/udp ndndock
docker run -d --rm --name ndn7 -p 6376:6363 -p 6377:6363/udp ndndock
docker run -d --rm --name ndn8 -p 6378:6363 -p 6379:6363/udp ndndock
docker run -d --rm --name ndn9 -p 6380:6363 -p 6381:6363/udp ndndock
docker run -d --rm --name ndn0 -p 6381:6363 -p 6383:6363/udp ndndock

# create bridge
#sudo ovs-vsctl del-br ovs-br1
#sudo ovs-vsctl add-br ovs-br1
#sudo ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up
#sudo ovs-vsctl show

#configure this bridge with NDN container
#sudo ovs-docker add-port ovs-br1 eth1 ndn1 --ipaddress=173.16.1.2/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn2 --ipaddress=173.16.1.3/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn3 --ipaddress=173.16.1.4/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn4 --ipaddress=173.16.1.5/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn5 --ipaddress=173.16.1.6/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn6 --ipaddress=173.16.1.7/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn7 --ipaddress=173.16.1.8/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn8 --ipaddress=173.16.1.9/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn9 --ipaddress=173.16.2.0/24
#sudo ovs-docker add-port ovs-br1 eth1 ndn0 --ipaddress=173.16.2.1/24

#FOR RUNNING ON THE HOST CLIENT
#install cmake
cd /users/ishitadg
version=3.12
build=2
mkdir temp
cd temp
wget https://cmake.org/files/v$version/cmake-$version.$build.tar.gz
tar -xzvf cmake-$version.$build.tar.gz
cd cmake-$version.$build/
./bootstrap
make -j4
sudo make install
cmake --version
# compile ndnperf client: 
cd /users/ishitadg/ndnperf/c++/client/
cmake . && make
#this installs Astreamer on Client host too
cd /users/ishitadg
wget -L https://github.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/blob/master/client.zip?raw=true
mv client.zip\?raw\=true client.zip
sudo apt-get install unzip
unzip client.zip
git clone --recursive https://github.com/pari685/AStream.git
rm client.zip;
cd AStream/dist; rm -rf client; mv ../../client/ .;

echo done
