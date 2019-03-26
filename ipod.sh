#!/bin/bash
read -p "Run how many clients? " answer
#IP SETUP
cd /users/ishitadg/AStream/dist/client; rm *.mpd; rm *.txt; rm -rf TEMP*; rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
export id=0
#RUN CLIENT STREAMING
for (( i=0; i<$answer; i++ )); do
  python dash_client_od.py -m http://10.10.1.2/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
  id=`expr $id + 1`
done
