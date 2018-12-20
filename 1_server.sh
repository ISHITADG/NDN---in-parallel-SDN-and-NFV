#!/bin/bash
#install bigbuckbunny video file
sudo apt-get -y install vim
sudo apt-get -y install tmux
cd /users/ishitadg/ndnperf/c++/server;
cp /proj/wrfhydro-PG0/www-itec.uni-klu.ac.at .;
#wget -r --no-parent --reject \"index.html*\" http://www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
cd www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/;
#wget 'http://emmy10.casa.umass.edu/CNP/BigBuckBunny_2s.mpd'
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/BigBuckBunny_2s.mpd
#mv /users/ishitadg/www-itec.uni-klu.ac.at/ .;
sudo apt-get update;
sudo apt-get -y install apache2;
/etc/init.d/apache2 restart;

sudo route del -net 10.0.0.0 netmask 255.0.0.0
sudo ip route add 10.0.0.0/8 via 10.10.1.4

echo done
