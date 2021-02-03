#!/bin/bash
read -p "Run how many clients? " answer
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  #reset journalct rate limiting off
  docker cp journald.conf ndn$i:/etc/systemd/;
  docker exec -ti ndn$i systemctl restart systemd-journald;
  #restart nfd & ndn-py-repo in dockers
  docker exec -ti ndn$i sudo systemctl stop nfd;
  docker exec -ti ndn$i sudo systemctl start nfd;
  docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256;
done
