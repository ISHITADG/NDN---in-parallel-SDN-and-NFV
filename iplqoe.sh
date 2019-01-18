#!/bin/bash
read -p "Run how many clients? " answer
#COPY RESULTS
mkdir /users/ishitadg/IPL; mkdir /users/ishitadg/IPL/DASH_BUFFER; mkdir /users/ishitadg/IPL/BOLA_LOG/;
cd /users/ishitadg/IPL/DASH_BUFFER;rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;
cd /users/ishitadg/IPL/BOLA_LOG; rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;

#RUN QOE
cd /users/ishitadg/; rm IPL/abr*; rm 5_qoeipl.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoeipl.py;
python 5_qoeipl.py;
mv abr* IPL/;
echo done;
