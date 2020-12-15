#!/bin/bash
read -p "Run how many clients? " answer
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  #restart nfd & ndn-py-repo in dockers
  docker exec -ti ndn$i sudo systemctl stop nfd;
  docker exec -ti ndn$i sudo systemctl start nfd;
  docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256;
done
