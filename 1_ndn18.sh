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

#install & start ndn-python-repo
apt install python3-pip
pip3 install python-ndn
git clone https://github.com/JonnyKong/ndn-python-repo.git
cd ndn-python-repo && /usr/bin/pip3 install -e .
sudo ndn-python-repo-install
sudo apt-get install -y sqlite3 libsqlite3-dev
cd ndn_python_repo
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndn-python-repo.conf.sample
systemctl stop ndn-python-repo; systemctl start ndn-python-repo
systemctl status ndn-python-repo
cd /users/ishitadg;

echo done