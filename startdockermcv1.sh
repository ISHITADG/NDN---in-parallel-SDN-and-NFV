#!/bin/bash
read -p "Run how many clients? " answer
docker rm -f $(docker ps -aq)
docker network rm mymcvn2
#setup mcvlan network 
docker network create -d macvlan --subnet 10.10.3.0/24 --ip-range 10.10.3.10/27 --gateway=10.10.3.254 --aux-address="router=10.10.3.4" --aux-address="host=10.10.3.1" -o parent=enp5s0f0 mymcvn1
#NDN Docker setup
port1=6364
port2=6365
##start docker over mcvlan
for (( i=0; i<$answer; i++ )); do
  docker run -d --network mymcvn1 --name ndn$i -p $port1:6363 -p $port2:6365/udp --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro ishitadg/ndn18
  port1=`expr $port1 + 2`
  port2=`expr $port2 + 2`
done
