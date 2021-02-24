#!/bin/bash
read -p "Run how many clients? " answer
#RUN CLIENT STREAMING
for (( i=0; i<$answer; i++ )); do
  #docker exec ndn$i tcpdump -i eth0 -w $i$".pcap" &
  docker exec ndn$i rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
  #docker exec -w /ndn-python-repo/examples/AStream/dist/client ndn$i taskset 0x00000001 python dashrepocat.py -m BigBuckBunny2s.mpd -p bola &
  docker exec -w /ndn-python-repo/examples/AStream/dist/client ndn$i taskset 0x00000001 python dash_client_live.py -m http://10.10.1.2/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
done
