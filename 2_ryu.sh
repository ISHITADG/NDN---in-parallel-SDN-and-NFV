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
sudo pip install tinyrpc
sudo pip install six --upgrade
