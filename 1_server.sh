#!/bin/bash
#install bigbuckbunny video file
sudo apt-get install vim
sudo apt-get install tmux
wget -r --no-parent --reject \"index.html*\" http://www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
sudo apt-get update
sudo apt-get install apache2

echo done
