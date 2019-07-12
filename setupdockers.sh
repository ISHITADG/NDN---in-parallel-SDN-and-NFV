#!/bin/bash
read -p "Run how many clients? " answer

#NDN Docker setup
port1=6364
port2=6365
ip=173.16.1.
network=2
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  docker kill ndn$i;
  docker run -d --rm --name ndn$i -p $port1:6363 -p $port2:6363/udp ndndock;
  port1=`expr $port1 + 2`
  port2=`expr $port2 + 2`
  ovs-docker add-port ovs-br1 eth1 ndn$i --ipaddress=$ip$network$"/24";
  network=`expr $network + 1`
  sudo ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up
  docker exec -ti ndn$i nfdc face create udp://173.16.1.1;
  docker exec -ti ndn$i nfdc route add /edu/umass udp://173.16.1.1;
  #for ndn over ethernet
  #docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256
done