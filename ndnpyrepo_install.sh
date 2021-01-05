#!/bin/bash
#install & start ndn-python-repo
apt install python3-pip;
pip3 install python-ndn;
git clone https://github.com/JonnyKong/ndn-python-repo.git;
cd ndn-python-repo && /usr/bin/pip3 install -e .;
sudo ndn-python-repo-install;
sudo apt-get install -y sqlite3 libsqlite3-dev;
cd ndn_python_repo;
rm ndn-python-repo.conf.sample;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndn-python-repo.conf.sample;
systemctl stop ndn-python-repo; systemctl start ndn-python-repo;
systemctl status ndn-python-repo;
cd ../../;

echo done
