#!/bin/bash
read -p "Run how many clients? " answer
#RUN CLIENT STREAMING
for (( i=0; i<$answer; i++ )); do
  docker exec ndn$i tcpdump -w  tcpdump$i -i eth1 udp port 6363 -vv &
  docker exec ndn$i ndndump -i eth1 > trace$i &
  docker exec -w /AStream/dist/client ndn$i taskset 0x00000001 python /AStream/dist/client/dash_client_onlympd.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
done
