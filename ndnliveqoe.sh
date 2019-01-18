#!/bin/bash
read -p "Run how many clients? " answer
#COPY RESULTS
mkdir /users/ishitadg/NDN; mkdir /users/ishitadg/NDN/DASH_BUFFER; mkdir /users/ishitadg/NDN/BOLA_LOG/;
cd /users/ishitadg/NDN/DASH_BUFFER;rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;
cd /users/ishitadg/NDN/BOLA_LOG; rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;

#RUN QOE
cd /users/ishitadg/; rm NDN/abr*; rm 5_qoendn.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoendn.py;
python 5_qoendn.py;
mv abr* NDN/;
echo done;
