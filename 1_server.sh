#!/bin/bash
#install bigbuckbunny video file
cd /users/ishitadg/ndnperf/c++/server;
sudo apt-get -y install vim
sudo apt-get -y install tmux
mkdir www-itec.uni-klu.ac.at;
mv /proj/wrfhydro-PG0/ftp www-itec.uni-klu.ac.at/;
cd www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/;
#wget 'http://emmy10.casa.umass.edu/CNP/BigBuckBunny_2s.mpd'
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/BigBuckBunny_2s.mpd
sudo apt-get update
sudo apt-get -y install apache2

echo done
