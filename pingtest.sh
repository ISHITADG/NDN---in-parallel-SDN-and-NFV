read -p "Run how many clients? " answer

#RUN CLIENT STREAMING
for (( i=0; i<$answer; i++ )); do
  docker exec ndn$i ndnping -i 1 -c 10000 -t /edu/umass > result$i.txt &
done
