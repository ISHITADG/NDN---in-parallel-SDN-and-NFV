############################### NDN Runs#####
#kill all dockers
docker kill ndn0;docker kill ndn1;docker kill ndn2;docker kill ndn3;docker kill ndn4;docker kill ndn5;docker kill ndn6;docker kill ndn7;docker kill ndn8;docker kill ndn9;
#start all dockers
docker run -d --rm --name ndn1 -p 6364:6363 -p 6365:6363/udp ndndock;docker run -d --rm --name ndn2 -p 6366:6363 -p 6367:6363/udp ndndock;docker run -d --rm --name ndn3 -p 6368:6363 -p 6369:6363/udp ndndock;docker run -d --rm --name ndn4 -p 6370:6363 -p 6371:6363/udp ndndock;docker run -d --rm --name ndn5 -p 6372:6363 -p 6373:6363/udp ndndock;docker run -d --rm --name ndn6 -p 6374:6363 -p 6375:6363/udp ndndock;docker run -d --rm --name ndn7 -p 6376:6363 -p 6377:6363/udp ndndock;docker run -d --rm --name ndn8 -p 6378:6363 -p 6379:6363/udp ndndock;docker run -d --rm --name ndn9 -p 6380:6363 -p 6381:6363/udp ndndock;docker run -d --rm --name ndn0 -p 6381:6363 -p 6383:6363/udp ndndock
#bridges
sudo ovs-docker add-port ovs-br1 eth1 ndn1 --ipaddress=173.16.1.2/24;sudo ovs-docker add-port ovs-br1 eth1 ndn2 --ipaddress=173.16.1.3/24;sudo ovs-docker add-port ovs-br1 eth1 ndn3 --ipaddress=173.16.1.4/24;sudo ovs-docker add-port ovs-br1 eth1 ndn4 --ipaddress=173.16.1.5/24;sudo ovs-docker add-port ovs-br1 eth1 ndn5 --ipaddress=173.16.1.6/24;sudo ovs-docker add-port ovs-br1 eth1 ndn6 --ipaddress=173.16.1.7/24;sudo ovs-docker add-port ovs-br1 eth1 ndn7 --ipaddress=173.16.1.8/24;sudo ovs-docker add-port ovs-br1 eth1 ndn8 --ipaddress=173.16.1.9/24;sudo ovs-docker add-port ovs-br1 eth1 ndn9 --ipaddress=173.16.2.0/24;sudo ovs-docker add-port ovs-br1 eth1 ndn0 --ipaddress=173.16.2.1/24

#not mandatory
@client:
docker ps
sudo docker exec -it ndn0  bash 
sudo docker exec -it ndn1 bash   
sudo docker exec -it ndn2 bash
sudo docker exec -it ndn3  bash
sudo docker exec -it ndn4 bash
sudo docker exec -it ndn5 bash
sudo docker exec -it ndn6 bash
sudo docker exec -it ndn7 bash
sudo docker exec -it ndn8 bash
sudo docker exec -it ndn9  bash

#establish docker ndn cnxns over udp
docker exec -ti ndn0 nfdc face create udp://173.16.1.1;docker exec -ti ndn0 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn1 nfdc face create udp://173.16.1.1; docker exec -ti ndn1 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn2 nfdc face create udp://173.16.1.1;docker exec -ti ndn2 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn3 nfdc face create udp://173.16.1.1;docker exec -ti ndn3 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn4 nfdc face create udp://173.16.1.1;docker exec -ti ndn4 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn5 nfdc face create udp://173.16.1.1;docker exec -ti ndn5 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn6 nfdc face create udp://173.16.1.1;docker exec -ti ndn6 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn7 nfdc face create udp://173.16.1.1;docker exec -ti ndn7 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn8 nfdc face create udp://173.16.1.1;docker exec -ti ndn8 nfdc route add /edu/umass udp://173.16.1.1;docker exec -ti ndn9 nfdc face create udp://173.16.1.1;docker exec -ti ndn9 nfdc route add /edu/umass udp://173.16.1.1;
#OR establish docker ndn cnxns over ethernet

#clear prev runs ON ALL:
cd /AStream/dist/client; rm Big*; rm *.txt; rm -rf TEMP*; rm /mnt/QUIClientServer0/ASTREAM_LOGS/*;
#Run ASTREAMER on 10 clients: NDN 
docker exec -w /AStream/dist/client ndn0 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn1 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn2 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn3 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn4 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn5 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn6 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn7 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn8 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola & docker exec -w /AStream/dist/client ndn9 python /AStream/dist/client/dash_client_udpD.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola;

#After run
#Once: 
mkdir /users/ishitadg/NDN; mkdir /users/ishitadg/NDN/DASH_BUFFER; mkdir /users/ishitadg/NDN/BOLA_LOG/;

#Move all dash buffer log:
cd /users/ishitadg/NDN/DASH_BUFFER; sudo rm *;docker cp ndn0:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG0.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn1:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG1.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn2:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG2.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn3:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG3.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn4:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG4.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn5:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG5.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn6:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG6.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn7:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG7.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn8:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG8.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn9:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG9.csv; sudo rm -rf ASTREAM_LOGS/;
#Move all bola log:
cd /users/ishitadg/NDN/BOLA_LOG; rm *;docker cp ndn0:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG0.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn1:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG1.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn2:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG2.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn3:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG3.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn4:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG4.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn5:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG5.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn6:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG6.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn7:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG7.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn8:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG8.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn9:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG9.csv; sudo rm -rf ASTREAM_LOGS/;
#run pythonscript on results
cd /users/ishitadg/; rm NDN/abr*; rm 5_qoendn.py;wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoendn.py;python 5_qoendn.py;mv abr* NDN/;
