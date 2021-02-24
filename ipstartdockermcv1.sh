#!/bin/bash
read -p "Run how many clients? " answer
docker rm -f $(docker ps -aq)
docker network rm mymcvn1
#setup mcvlan network 
docker network create -d macvlan --subnet=10.10.4.0/24 --gateway=10.10.4.1 --aux-address="exclude1=10.10.4.2" --aux-address="exclude2=10.10.4.4" --ip-range=10.10.4.10/27 -o parent=enp6s0f1 mymcvn1
#NDN Docker setup
port1=6364
port2=6365
##start docker over mcvlan
for (( i=0; i<$answer; i++ )); do
  docker run -d --network mymcvn1 --name ndn$i -p $port1:6363 -p $port2:6365/udp ishitadg/ndn18
  docker exec --privileged ndn$i ip route add 10.0.0.0/8 via 10.10.4.4 dev eth0
  port1=`expr $port1 + 2`
  port2=`expr $port2 + 2`
done
