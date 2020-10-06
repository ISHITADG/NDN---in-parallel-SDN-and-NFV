#!/bin/bash
#install all NDN dependencies and tools
sudo apt-get update
sudo apt install -y build-essential libboost-all-dev libssl-dev libsqlite3-dev pkg-config python-minimal
sudo apt install -y doxygen graphviz python3-pip
sudo pip3 install sphinx sphinxcontrib-doxylink
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:named-data/ppa -y
sudo apt-get update

#install nfd & others
sudo apt-get install -y ndn-cxx-dev
sudo apt-get install -y ndn-cxx
sudo apt install -y nfd
sudo apt-get install -y ndn-tools
sudo cp /usr/local/etc/ndn/nfd.conf.sample /usr/local/etc/ndn/nfd.conf
#adding security element
sudo ndnsec-keygen /`whoami` | ndnsec-install-cert -
sudo mkdir -p /usr/local/etc/ndn/keys
sudo ndnsec-cert-dump -i /`whoami` > default.ndncert
sudo mv default.ndncert /usr/local/etc/ndn/keys/default.ndncert
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
#ndnperf server & client
cd /users/ishitadg;
git clone https://github.com/Kanemochi/ndnperf.git
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/server.cpp
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/client.cpp
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/CMakeLists.txt
mv server.cpp ndnperf/c++/server/;
mv CMakeLists.txt ndnperf/c++/server/;
mv client.cpp ndnperf/c++/client/
cd ndnperf/c++/server/;
cmake . && make;
mv bin/ndnperfserver .;
cd ../client;
cmake . && make;
mv bin/ndnperf .;
cd ./users/ishitadg;

#install & start ndn-python-repo
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnpyrepo_install.sh;
bash ndnpyrepo_install.sh;
cd /users/ishitadg;

echo done
