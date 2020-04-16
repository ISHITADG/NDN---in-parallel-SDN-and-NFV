#!/bin/bash
#install ryu on controller
sudo apt-get update
sudo apt-get install --yes libxml2-dev libxslt1-dev python-dev python-eventlet python-routes python-webob python-paramiko python-setuptools python-pip
git clone git://github.com/osrg/ryu.git
cd ryu
sudo pip install -r tools/pip-requires
sudo python setup.py install
wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
sudo pip install oslo.config
sudo pip install tinyrpc==0.8
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python2.7/dist-packages
export PATH=$PATH:/usr/local/lib/python2.7/dist-packages
sudo pip install six --upgrade
