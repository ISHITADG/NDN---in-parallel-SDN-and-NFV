#!/bin/bash
read -p "Run how many IP & NDN clients each? " answer

#IP & NDN Docker setup
port1=6364
port2=6365
ip=173.16.1.
network=2
cd /users/ishitadg/AStream/dist/client; rm *.mpd; rm *.txt; rm -rf TEMP*; rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
export id=0
for (( i=0; i<$answer; i++ )); do
  docker kill ndn$i;
  docker run -d --rm --name ndn$i -p $port1:6363 -p $port2:6363/udp ndndock;
  port1=`expr $port1 + 2`
  port2=`expr $port2 + 2`
  ovs-docker add-port ovs-br1 eth1 ndn$i --ipaddress="$ip$network$'/24'";
  network=`expr $network + 1`
  ##for ndn over OVS
  #docker exec -ti ndn$i nfdc face create udp://173.16.1.1;
  #docker exec -ti ndn$i nfdc route add /edu/umass udp://173.16.1.1;
  #for ndn over ethernet
  docker exec -ti ndn$i nfdc route add /edu/umass nexthop 256
done

#RUN/STREAM OVER IP and NDN
for (( i=0; i<$answer; i++ )); do
  docker exec -w /AStream/dist/client ndn$i python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & python dash_client.py -m http://10.10.1.1/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola &
  id=`expr $id + 1`
done

#COPY RESULTS
mkdir /users/ishitadg/IPNDN; mkdir /users/ishitadg/IPNDN/DASH_BUFFER; mkdir /users/ishitadg/IPNDN/BOLA_LOG/;
cd /users/ishitadg/IPNDN/DASH_BUFFER; sudo rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;
cp /mnt/QUIClientServer0/ASTREAM_LOGS/DASH_BUFFER* .;

cd /users/ishitadg/NDN/BOLA_LOG; rm *;
for (( i=0; i<$answer; i++ )); do
  docker cp ndn$i:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;
  sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG$i$'.csv';
done
sudo rm -rf ASTREAM_LOGS/;
cp /mnt/QUIClientServer0/ASTREAM_LOGS/BOLA_LOG* .;

#RUN QoE
cd /users/ishitadg/; rm IPNDN/abr*; rm 5_qoeipndn.py;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoendn.py;
python 5_qoeipndn.py;
mv abr* IPNDN/;
echo done;
