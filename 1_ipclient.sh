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

#ASTreamer for Client host too
cd /users/ishitadg;
wget -L https://github.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/blob/master/client.zip?raw=true;
mv client.zip\?raw\=true client.zip;
sudo apt-get install unzip;
unzip client.zip;
git clone --recursive https://github.com/pari685/AStream.git;
rm client.zip;
cd AStream/dist; rm -rf client; mv ../../client/ .;

#install all scripts for ondemand
cd /users/ishitadg/AStream/dist/client;
rm dash_client_od.py;
rm configure_log_file.py;
rm config_dash.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/configure_log_file.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_od.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/config_dash.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipod.sh; 
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipodqoe.sh;
#scripts for live
cd /users/ishitadg;
wget -L https://raw.githubusercontent.com/ISHITADG/dockerNDN/master/dockovs.sh;
bash dockovs.sh;
docker pull ishitadg/ndn18;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/iplive.sh;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipliveqoe.sh;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipstartdockermcv1.sh;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoeipl.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoeip.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_live.py;

echo done
