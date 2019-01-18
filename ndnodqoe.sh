#!/bin/bash
read -p "Run how many clients? " answer
#COPY RESULTS
mkdir /users/ishitadg/NDNO; mkdir /users/ishitadg/NDNO/DASH_BUFFER; mkdir /users/ishitadg/NDNO/BOLA_LOG/;
cd /users/ishitadg/NDNO/DASH_BUFFER; sudo rm *;cp /mnt/QUIClientServer0/ASTREAM_LOGS/DASH_BUFFER* .;
cd /users/ishitadg/NDNO/BOLA_LOG; sudo rm *;cp /mnt/QUIClientServer0/ASTREAM_LOGS/BOLA_LOG* .;

##if IP over Docker client : comment previous 2 lines and uncomment next commented lines
#for (( i=0; i<$answer; i++ )); do
#  docker exec -w /AStream/dist/client ndn$i python dash_client.py -m http://10.10.1.1/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
#done
#cd /users/ishitadg/IP/DASH_BUFFER; sudo rm *;
#for (( i=0; i<$answer; i++ )); do
#  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
#  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG$i$'.csv';
#done
#sudo rm -rf ASTREAM_LOGS/;
#cd /users/ishitadg/IP/BOLA_LOG; rm *;
#for (( i=0; i<$answer; i++ )); do
#  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
#  sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG$i$'.csv';
#done
#sudo rm -rf ASTREAM_LOGS/;

#RUN QoE
cd /users/ishitadg/; rm NDNO/abr*; rm 5_qoendnod.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoendnod.py;
python 5_qoendnod.py;
mv abr* NDNO/;
echo done;
