#!/bin/bash
read -p "Run how many IP & NDN clients each? " answer

#COPY RESULTS
mkdir /users/ishitadg/IPNDN; mkdir /users/ishitadg/IPNDN/DASH_BUFFER; mkdir /users/ishitadg/IPNDN/BOLA_LOG/;
cd /users/ishitadg/IPNDN/DASH_BUFFER; sudo rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;
cp /mnt/QUIClientServer0/ASTREAM_LOGS/DASH_BUFFER* .;

cd /users/ishitadg/NDN/BOLA_LOG; rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;
cp /mnt/QUIClientServer0/ASTREAM_LOGS/BOLA_LOG* .;

#RUN QoE
cd /users/ishitadg/; rm IPNDN/abr*; rm 5_qoeipndn.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoendn.py;
python 5_qoeipndn.py;
mv abr* IPNDN/;
echo done;
