#!/bin/bash
read -p "Run how many clients? " answer

wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/nfd.conf;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_onlympd.py;
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  #reset nfd config & simple mpd download script copy
  docker cp dash_client_onlympd.py ndn$i:AStream/dist/client/; 
  docker cp nfd.conf ndn$i:/usr/local/etc/ndn/nfd.conf;
  #restart nfd in dockers
  docker exec -ti ndn$i systemctl stop nfd;
  docker exec -ti ndn$i start nfd;
  docker exec -ti ndn$i nfdc route add /edu/umass nexthop 257;
  #docker exec -ti ndn$i nfdc face create udp://173.16.1.1;
  #docker exec -ti ndn$i nfdc route add /edu/umass udp://173.16.1.1;
done
