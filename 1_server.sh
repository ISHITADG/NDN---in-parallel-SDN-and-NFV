#!/bin/bash
#install bigbuckbunny video file
sudo apt-get install vim
sudo apt-get install tmux
wget -r --no-parent --reject \"index.html*\" http://www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
cd www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
#wget 'http://emmy10.casa.umass.edu/CNP/BigBuckBunny_2s.mpd'
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/BigBuckBunny_2s.mpd
sudo apt-get update
sudo apt-get install apache2

echo done
