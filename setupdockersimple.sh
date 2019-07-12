#!/bin/bash
read -p "Run how many clients? " answer

#NDN Docker setup
port1=6364
port2=6365
for (( i=0; i<$answer; i++ )); do
  docker kill ndn$i;
  docker run -d --rm --name ndn$i -p $port1:6363 -p $port2:6363/udp ndndock;
  port1=`expr $port1 + 2`
  port2=`expr $port2 + 2`
  docker exec -ti ndn$i nfdc face create udp://172.17.0.1;
  docker exec -ti ndn$i nfdc route add /edu/umass udp://172.17.0.1;
  #for ndn over ethernet
  #docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256
done
