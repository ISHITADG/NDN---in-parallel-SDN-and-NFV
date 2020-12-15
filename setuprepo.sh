#!/bin/bash
read -p "Run how many clients? " answer
##for ndn over OVS
for (( i=0; i<$answer; i++ )); do
  #restart ndn-py-repo in dockers
  docker exec -w /ndn-python-repo/ndn_python_repo ndn$i systemctl stop ndn-python-repo;
  docker exec -w /ndn-python-repo/ndn_python_repo ndn$i systemctl start ndn-python-repo;
done
