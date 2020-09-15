#!/bin/bash
read -p "Run how many clients? " answer
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  #reset nfd config & simple mpd download script copy
  docker cp dash_client_onlympd.py ndn$i:AStream/dist/client/;
  docker cp nfd.conf ndn$i:/etc/ndn/nfd.conf;
  #restart nfd in dockers
  docker exec -ti ndn$i sudo systemctl stop nfd;
  docker exec -ti ndn$i sudo systemctl start nfd;
  docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256;
  #docker exec -ti ndn$i nfdc face create udp://173.16.1.1;
  #docker exec -ti ndn$i nfdc route add /edu/umass udp://173.16.1.1;
done
