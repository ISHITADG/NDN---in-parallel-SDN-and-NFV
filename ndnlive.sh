#!/bin/bash
read -p "Run how many clients? " answer
#RUN CLIENT STREAMING
for (( i=0; i<$answer; i++ )); do
  #docker exec ndn$i rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
  #docker exec -w /AStream/dist/client ndn$i taskset 0x00000001 python new.py -m BigBuckBunny2s.mpd -p bola &
  #docker exec -w /AStream/dist/client ndn$i taskset 0x00000001 python new.py -m BigBuckBunny2s.mpd -p squad &
  docker exec -w /AStream/dist/client ndn$i taskset 0x00000001 python dashrepocat.py -m BigBuckBunny2s.mpd -p bola &
done
