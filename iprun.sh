#!/bin/bash
cd /users/ishitadg/AStream/dist/client; rm Big*; rm *.txt; rm -rf TEMP*; rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
cd /users/ishitadg/AStream/dist/client; rm dash_client.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client.py;
export id=0
for (( i=0; i<10; i++ )); do
  python dash_client.py -m http://10.10.1.1/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
  id=`expr $id + 1`
done
