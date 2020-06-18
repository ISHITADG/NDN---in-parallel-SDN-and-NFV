#!/bin/bash
read -p "Run how many clients? " answer
#setup mcvlan network 
docker network create -d macvlan -o parent=enp5s0f0 --subnet 10.10.3.0/24 --gateway 0.0.0.0 --ip-range 10.10.3.10/27 mymcvn1
#NDN Docker setup
docker rm -f $(docker ps -aq)
port1=6364
port2=6365
##start docker over mcvlan
for (( i=0; i<$answer; i++ )); do
  docker run -d --network mymcvn1 --name ndn$i -p $port1:6363 -p $port2:6365/udp --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro ishitadg/ndn18
  port1=`expr $port1 + 2`
  port2=`expr $port2 + 2`
done
