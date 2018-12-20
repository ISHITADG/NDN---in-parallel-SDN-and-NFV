#!/bin/bash
read -p "Run how many clients? " answer
#IP SETUP
cd /users/ishitadg/AStream/dist/client; rm *.mpd; rm *.txt; rm -rf TEMP*; rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
export id=0
#RUN CLIENT STREAMING
for (( i=0; i<$answer; i++ )); do
  python dash_client.py -m http://10.10.1.1/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
  id=`expr $id + 1`
done
#COPY RESULTS
mkdir /users/ishitadg/IP; mkdir /users/ishitadg/IP/DASH_BUFFER; mkdir /users/ishitadg/IP/BOLA_LOG/;
cd /users/ishitadg/IP/DASH_BUFFER; sudo rm *;cp /mnt/QUIClientServer0/ASTREAM_LOGS/DASH_BUFFER* .;
cd /users/ishitadg/IP/BOLA_LOG; sudo rm *;cp /mnt/QUIClientServer0/ASTREAM_LOGS/BOLA_LOG* .;

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
cd /users/ishitadg/; rm IP/abr*; rm 5_qoeip.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoeip.py;
python 5_qoeip.py;
mv abr* IP/;
echo done;
