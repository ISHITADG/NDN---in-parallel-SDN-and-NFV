#!/bin/bash
#install bigbuckbunny video file
sudo apt-get -y install vim
sudo apt-get -y install tmux
git clone https://github.com/esnet/iperf.git;
cd iperf;
./configure;
make;
make install;
ldconfig;
iperf3 -v;

#install data to be downloaded for IP
sudo apt-get update;
sudo apt-get -y install apache2;
/etc/init.d/apache2 restart;
cd /var/www/html;
cp -r /proj/CDNABRTest/www-itec.uni-klu.ac.at .;
ln -s www-itec.uni-klu.ac.at livedata;
#ln -s /proj/CDNABRTest/www-itec.uni-klu.ac.at livedata;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ondemand.py; 
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ondemand.txt;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/livestream_timer.py

#install data to be downloaded over ndn
cd /users/ishitadg/ndn-python-repo/examples/
#cp -r /proj/CDNABRTest/www-itec.uni-klu.ac.at .;
#ln -s www-itec.uni-klu.ac.at ondemand;
#ln -s /proj/CDNABRTest/www-itec.uni-klu.ac.at www-itec.uni-klu.ac.at;
#ln -s /proj/CDNABRTest/www-itec.uni-klu.ac.at ondemand;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/livestream_timer.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ondemand.py; 
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/upload.sh; 
echo "BEGIN SERVER DATABASE UPLOAD or DATABASE TRASNFER"
rm /root/.ndn/ndn-python-repo/sqlite3.db;
cp -r /proj/CDNABRTest/sqlite3.db /root/.ndn/ndn-python-repo/sqlite3.db;
#bash upload.sh

echo done
