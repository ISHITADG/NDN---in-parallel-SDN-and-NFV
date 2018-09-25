#!/bin/bash

sudo apt-get install python-pip python-dev build-essential
sudo pip install httplib2 --upgrade
sudo pip install numpy scipy

#SETUP DOCKER AND OPENVSWITCH
sudo wget https://raw.githubusercontent.com/ISHITADG/dockerNDN/master/dockovs.sh
bash dockovs.sh

#SETUP NDN DOCKER

#download Dockerfile(includes downloading Astreamer and Bhushan's client code)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/Dockerfile;

#build docker ndn docker type
docker build -t ndndock --build-arg VERSION_CXX=ndn-cxx-0.6.1 --build-arg VERSION_NFD=NFD-0.6.1 .

#Run NDN docker
docker run -d --rm --name ndn1 -p 6364:6363 -p 6365:6363/udp ndndock

rm client.zip;
cd AStream/dist; rm -rf client; mv ../../client/ .;

echo done
