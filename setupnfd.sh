#!/bin/bash
read -p "Run how many clients? " answer
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  #reset journalct rate limiting off
  #docker cp journald.conf ndn$i:/etc/systemd/;
  #docker exec -ti ndn$i systemctl restart systemd-journald;
  #restart nfd & ndn-py-repo in dockers
  #docker cp /users/ishitadg/ndn-python-repo/examples/dashrepocat.py ndn$i:AStream/dist/client
  #docker cp /users/ishitadg/ndn-python-repo/examples/new.py ndn$i:AStream/dist/client
  #docker cp /users/ishitadg/ndn-python-repo/examples/newconfig.py ndn$i:AStream/dist/client/config_dash.py
  docker exec -ti ndn$i sudo systemctl stop nfd;
  docker exec -ti ndn$i sudo systemctl start nfd;
  docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256;
  docker exec -ti ndn$i systemctl mask systemd-journald.service;
done
