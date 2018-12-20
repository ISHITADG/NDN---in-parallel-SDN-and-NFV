#!/bin/bash
cd /users/ishitadg/AStream/dist/client; rm *.mpd; rm *.txt; rm -rf TEMP*; rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
export id=0
for (( i=0; i<10; i++ )); do
  python dash_client.py -m http://10.10.1.1/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
  id=`expr $id + 1`
done
