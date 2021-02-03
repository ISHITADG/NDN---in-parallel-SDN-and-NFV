#!/bin/bash
read -p "Run how many clients? " answer
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  #reset journalct rate limiting off 
  docker exec -ti ndn$i wget https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/journald.conf;
  docker exec -ti ndn$i mv journald.conf /etc/systemd/;
  docker exec -ti ndn$i systemctl restart systemd-journald;
  #restart nfd & ndn-py-repo in dockers
  docker exec -ti ndn$i sudo systemctl stop nfd;
  docker exec -ti ndn$i sudo systemctl start nfd;
  docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256;
done
