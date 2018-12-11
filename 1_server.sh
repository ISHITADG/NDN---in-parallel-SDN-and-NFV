#!/bin/bash
#install bigbuckbunny video file
sudo apt-get -y install vim
sudo apt-get -y install tmux
wget -r --no-parent --reject \"index.html*\" http://www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
cd www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
#wget 'http://emmy10.casa.umass.edu/CNP/BigBuckBunny_2s.mpd'
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/BigBuckBunny_2s.mpd
cd /users/ishitadg/ndnperf/c++/server;
mv /users/ishitadg/www-itec.uni-klu.ac.at/ .;
sudo apt-get update;
sudo apt-get -y install apache2;
/etc/init.d/apache2 restart;

echo done
