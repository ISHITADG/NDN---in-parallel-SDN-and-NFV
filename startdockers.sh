#!/bin/bash
read -p "Run how many clients? " answer

#NDN Docker setup
docker rm -f $(docker ps -aq)
sudo ovs-vsctl del-br ovs-br1
sudo ovs-vsctl add-br ovs-br1
sudo ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up
ip=173.16.1.
network=2
port1=6364
port2=6365
sudo ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up
ovsadd=$(cat /sys/class/net/ovs-br1/address)
echo "enter ethernet port name for this client: " 
read e1
ovs-vsctl add-port ovs-br1 $e1
ovs-vsctl set Bridge ovs-br1 other_config:hwaddr=$ovsadd
echo "IP address of SDN controller: "
read sdnip
ovs-vsctl set-controller ovsbr0 tcp:$sdnip:6633
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  docker run -d --name ndn$i -p $port1:6363 -p $port2:6365/udp --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro ishitadg/ndn18
  ovs-docker add-port ovs-br1 eth1 ndn$i --ipaddress=$ip$network$"/24";
  network=`expr $network + 1`
  port1=`expr $port1 + 2`
  port2=`expr $port2 + 2`
done
