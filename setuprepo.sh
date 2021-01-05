#!/bin/bash
read -p "Run how many clients? " answer
##for ndn over OVS
port=7000
#dld config file
rm ndn-python-repo.conf*;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndn-python-repo.conf.sample;
for (( i=0; i<$answer; i++ )); do
  #modify port number line in config file before sending to the respective container
  line=$"  'port': '"$port"'"
  sed -i "26s|.*|$line|g" ndn-python-repo.conf.sample
  #restart ndn-py-repo in dockers
  docker exec -w /ndn-python-repo/ndn_python_repo ndn$i rm ndn-python-repo.conf*;
  docker cp ndn-python-repo.conf.sample ndn$i:ndn-python-repo/ndn_python_repo;
  docker exec -w /ndn-python-repo/ndn_python_repo ndn$i systemctl stop ndn-python-repo;
  docker exec -w /ndn-python-repo/ndn_python_repo ndn$i systemctl start ndn-python-repo;
  #increment port number for next container
  port=`expr $port + 1`
done
