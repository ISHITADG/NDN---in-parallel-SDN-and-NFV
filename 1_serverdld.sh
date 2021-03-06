#!/bin/bash
#install bigbuckbunny video file
sudo apt-get -y install vim
sudo apt-get -y install tmux
#git clone https://github.com/esnet/iperf.git;
#cd iperf;
#./configure;
#make;
#make install;
#ldconfig;
#iperf3 -v;
cd /users/ishitadg/ndnperf/c++/server;
wget -r --no-parent --reject \"index.html*\" http://www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
cd www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/BigBuckBunny_2s.mpd
cd /users/ishitadg/ndnperf/c++/server;
ln -s www-itec.uni-klu.ac.at ondemand;
ndnsec-keygen /`whoami` | ndnsec-install-cert -;
sudo mkdir -p /usr/local/etc/ndn/keys;
ndnsec-cert-dump -i /`whoami` > default.ndncert;
sudo mv default.ndncert /usr/local/etc/ndn/keys/default.ndncert;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/livestream_timer.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ondemand.py; 
cd /proj/CDNABRTest/;
cp -r /users/ishitadg/ndnperf/c++/server/www-itec.uni-klu.ac.at .;
sudo apt-get update;
sudo apt-get -y install apache2;
/etc/init.d/apache2 restart;
cd /var/www/html;
cp -r /users/ishitadg/ndnperf/c++/server/www-itec.uni-klu.ac.at .;
ln -s www-itec.uni-klu.ac.at livedata;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ondemand.py; 
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/livestream_timer.py

echo done
