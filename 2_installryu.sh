sudo -s
apt-get update
apt-get install --yes libxml2-dev libxslt1-dev python-dev python-eventlet python-routes python-webob python-paramiko python-setuptools python-pip
git clone git://github.com/osrg/ryu.git
cd ryu
sudo pip install -r tools/pip-requires
sudo python setup.py install
wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python
pip install oslo.config
pip install tinyrpc
