#!/bin/bash
read -p "Run how many clients? " answer
#COPY RESULTS
mkdir -p /users/ishitadg/IPL; mkdir -p /users/ishitadg/IPL/DASH_BUFFER; mkdir -p /users/ishitadg/IPL/BOLA_LOG/;
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
cd /users/ishitadg/; rm IPL/abr*;
python 5_qoeipl.py;
mv abr* NDN/;
echo done;
