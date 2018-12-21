#!/bin/bash
read -p "Run how many clients? " answer

#NDN Docker setup
port1=6364
port2=6365
ip=173.16.1.
network=2
##for ndn over OVS
#sudo ovs-vsctl del-br ovs-br1
#sudo ovs-vsctl add-br ovs-br1
#sudo ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up
for (( i=0; i<$answer; i++ )); do
  docker kill ndn$i;
  docker run -d --rm --name ndn$i -p $port1:6363 -p $port2:6363/udp ndndock;
  port1=`expr $port1 + 2`
  port2=`expr $port2 + 2`
  ovs-docker add-port ovs-br1 eth1 ndn$i --ipaddress="$ip$network$'/24'";
  network=`expr $network + 1`
  #sudo ifconfig ovs-br1 173.16.1.1 netmask 255.255.255.0 up
  #docker exec -ti ndn$i nfdc face create udp://173.16.1.1;
  #docker exec -ti ndn$i nfdc route add /edu/umass udp://173.16.1.1;
  #for ndn over ethernet
  docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256
done

#RUN CLIENT STREAMING
for (( i=0; i<$answer; i++ )); do
  docker exec -w /AStream/dist/client ndn$i python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
done
disown

#COPY RESULTS
mkdir /users/ishitadg/NDN; mkdir /users/ishitadg/NDN/DASH_BUFFER; mkdir /users/ishitadg/NDN/BOLA_LOG/;
cd /users/ishitadg/NDN/DASH_BUFFER;rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;
cd /users/ishitadg/NDN/BOLA_LOG; rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;

#RUN QOE
cd /users/ishitadg/; rm NDN/abr*; rm 5_qoendn.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoendn.py;
python 5_qoendn.py;
mv abr* NDN/;
echo done;
