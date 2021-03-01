#!/bin/bash
read -p "Run how many clients? " answer
#IP SETUP
cd /users/ishitadg/AStream/dist/client; rm *.mpd; rm -rf TEMP*; rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
export id=0
#RUN CLIENT STREAMING
for (( i=0; i<$answer; i++ )); do
	taskset 0x00000001 python ondashrepocat.py -m BigBuckBunny2s.mpd -p bola &
	id=`expr $id + 1`
done
