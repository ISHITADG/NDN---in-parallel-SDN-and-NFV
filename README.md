# NDN---in-parallel-SDN-and-NFV: An Evaluation of SDN and NFV Support for Parallel, Alternative Protocol Stack Operations on CloudLab (UPDATED FOR LATEST UBUNTU 18 VERSION)
## STEP 1: Server & client setup:
### NDN SETUP ON ALL REQUIRED NODES:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn18.sh <br/>
bash 1_ndn18.sh <br/>
### SERVER setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_server.sh <br/>
bash 1_server.sh <br/>
*OR* <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_serverdld.sh <br/>
bash 1_serverdld.sh <br/>
### CLIENT SETUP:
#### FOR NDN CLIENTS
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndnclient.sh <br/>
bash 1_ndnclient.sh <br/>
#### FOR IP CLIENTS
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ipclient.sh <br/>
bash 1_ipclient.sh <br/>

## STEP 2: Controller setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/2_ryu.sh <br/>
bash 2_ryu.sh <br/>
cd ryu/ <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/controllerhalfbig.py <br/>
ryu-manager controller.py <br/>
(print dpid and modify line 66 accordingly) <br/>
(Run controller again) <br/>
## STEP 3: Bridge setup on Routers:
### INSTALL & START VMs
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/3_vmsetup.sh <br/>
bash 3_vmsetup.sh <br/>
// reset & check ipVM, ndnVM network config.

## STEP 4: SETUP ROUTER VMs
### Setup IPVM - check end-to-end pings
#### @ Router VM:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/00-installer-config.yaml;<br/>
mv  00-installer-config.yaml /etc/netplan/;<br/>
sysctl -w net.ipv4.ip_forward=1;<br/>
sudo netplan apply;<br/>
R1,R2,R3: ip route add 10.0.0.0/8 via 10.10.3.5 dev ens16<br/>
R1: ip route add 10.10.7.0/24 via 10.10.2.5 dev ens8<br/>
R1: ip route add 10.10.8.0/21 via 10.10.2.5 dev ens8<br/>
#### @ server & other client nodes: 
!!Update Routes!!  <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.1.4; <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.2.4; <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.3.4; <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.4.4; <br/>
#### ADD Traffic control rules
!!!TC RULE INSTALLATION!!! <br/>
>>SERVER <br/>
tc qdisc del dev enp9s4f0 root <br/>
tc qdisc add dev enp9s4f0 handle 1: root htb default 11 <br/>
tc class add dev enp9s4f0 parent 1: classid 1:1 htb rate 10mbit  <br/>
tc class add dev enp9s4f0 parent 1:1 classid 1:11 htb rate 6mbit <br/>
tc class add dev enp9s4f0 parent 1:1 classid 1:12 htb rate 4mbit <br/>
tc filter add dev enp9s4f0 parent 1: protocol ip prio 1 u32 match ip src 10.10.1.2 match ip dst 10.10.4.2 flowid 1:12 <br/>
>>ROUTER (server's link) <br/>
tc qdisc del dev enp6s0f3 root <br/>
tc qdisc add dev enp6s0f3 handle 1: root htb default 11 <br/>
tc class add dev enp6s0f3 parent 1: classid 1:1 htb rate 10mbit  <br/>
tc class add dev enp6s0f3 parent 1:1 classid 1:11 htb rate 6mbit <br/>
tc class add dev enp6s0f3 parent 1:1 classid 1:12 htb rate 4mbit <br/>
tc filter add dev enp6s0f3 parent 1: protocol ip prio 1 u32 match ip src 10.10.4.2 match ip dst 10.10.1.2 flowid 1:12  <br/>
>>OTHERS <br/>
tc qdisc del dev eno2 root <br/>
tc qdisc add dev eno2 handle 1: root htb default 11 <br/>
tc class add dev eno2 parent 1:1 classid 1:11 htb rate 100mbit <br/>
tc qdisc del dev eno4 root <br/>
tc qdisc add dev eno4 handle 1: root htb default 11 <br/>
tc class add dev eno4 parent 1:1 classid 1:11 htb rate 100mbit <br/>
tc qdisc del dev enp5s0f1 root <br/>
tc qdisc add dev enp5s0f1 handle 1: root htb default 11 <br/> 
tc class add dev enp5s0f1 parent 1:1 classid 1:11 htb rate 100mbit  <br/>
tc qdisc del dev enp5s0f0 root <br/>
tc qdisc add dev enp5s0f0 handle 1: root htb default 11 <br/>
tc class add dev enp5s0f0 parent 1:1 classid 1:11 htb rate 100mbit <br/>
tc qdisc del dev enp4s0f1 root <br/>
tc qdisc add dev enp4s0f1 handle 1: root htb default 11 <br/>
tc class add dev enp4s0f1 parent 1:1 classid 1:11 htb rate 100mbit <br/>
tc qdisc del dev enp6s0f0 root <br/>
tc qdisc add dev enp6s0f0 handle 1: root htb default 11 <br/>
tc class add dev enp6s0f0 parent 1:1 classid 1:11 htb rate 100mbit <br/>
tc qdisc del dev enp6s0f1 root <br/>
tc qdisc add dev enp6s0f1 handle 1: root htb default 11 <br/>
tc class add dev enp6s0f1 parent 1:1 classid 1:11 htb rate 100mbit <br/>
tc qdisc del dev enp6s0f2 root <br/>
tc qdisc add dev enp6s0f2 handle 1: root htb default 11 <br/>
tc class add dev enp6s0f2 parent 1:1 classid 1:11 htb rate 100mbit <br/>
tc qdisc del dev enp6s0f3 root <br/>
tc qdisc add dev enp6s0f3 handle 1: root htb default 11 <br/>
tc class add dev enp6s0f3 parent 1:1 classid 1:11 htb rate 100mbit <br/>
### Setup NDNVM
#### At router VM:
ifconfig ens7 up<br/>
ifconfig ens8 up<br/>
ifconfig ens9 up<br/>
ifconfig ens16 up<br/>
ifconfig ens17 up<br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnpyrepo_install.sh;<br/>
bash ndnpyrepo_install.sh;<br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/nfd500.conf <br/>
mv nfd500.conf /etc/ndn/nfd.conf<br/>
sudo systemctl stop nfd;sudo systemctl start nfd<br/>
#### At rest all:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/nfd.conf <br/>
mv nfd.conf /etc/ndn/<br/>
sudo systemctl stop nfd;sudo systemctl start nfd<br/>
#### Add routes @ router+clients
nfdc face<br/>
router: nfdc route add prefix /edu/umass nexthop 258<br/>
client: nfdc route add prefix /edu/umass nexthop 257<br/>
##### NDNPING TEST
ndnpingserver -t /edu/umass <br/>
ndnping -c 4 -t ndn:/edu/umass<br/>
##### NDNPERF TEST
./ndnperfserver -p ndn:/edu/umass -c 1500 -f 3600000 | "./ndnperf -p ndn:/edu/umass -d <filename> -w 16"<br/>
##### SEE LOGS OR DUMP TRACES
journalctl -u nfd<br/>
tcpdump -i eno4 -w 1.pcap "(ether proto 0x8624) or (tcp port 6363) or (udp port 6363) or (udp port 56363)"<br/>
tcpdump -i enp5s0f1 -w 1.pcap "(ether proto 0x8624) or (tcp port 6363) or (udp port 6363) or (udp port 56363)"<br/>
tcpdump -i enp5sof0 -w 1.pcap "(ether proto 0x8624) or (tcp port 6363) or (udp port 6363) or (udp port 56363)"<br/>

## STEP 5: START & SETUP NDN DOCKER CLIENTS FOR FINAL STEP
### To remove limit on journal logs do the following
wget https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/journald.conf; <br/>
mv journald.conf /etc/systemd/; <br/>
systemctl restart systemd-journald; <br/>

### Start streaming
cd /users/ishitadg/ndn-python-repo/examples/;<br/>
vim startdockermcv1.sh;<br/>
bash startdockermcv1.sh;<br/>
vim startdockermcv2.sh;<br/>
bash startdockermcv2.sh;<br/>
bash setupdockers.sh;<br/>
for (( i=0; i<10; i++ )); do docker cp dash_client_onlympd.py ndn$i:AStream/dist/client/; docker cp nfd.conf ndn$i:/usr/local/etc/ndn/nfd.conf; done

## STEP 6: SAMPLE TEST SINGLE FILE DOWNLOADS AT CLIENTS OVER NDN-PYTHON-REPO
### @ Server (only for single file upload dwnload test)
@cd /users/ishitadg/ndn-python-repo/ndn_python_repo;<br/>
systemctl stop ndn-python-repo; systemctl start ndn-python-repo;<br/>
systemctl status ndn-python-repo;<br/>
cd /users/ishitadg/ndn-python-repo/examples/;<br/>
python3 putfile.py -r bigbuckbunny --register_prefix /edu/umass -f www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd  -n /edu/umass/BigBuckBunny_2s.mpd;<br/>
### @ Router NDNVM
cd ndn-python-repo/examples/;<br/>
python3 getfile.py -r bigbuckbunny -n /edu/umass/bunny_89283bps/bunny_89283bps_BigBuckBunny_2s299.m4s<br/>
python3 getfile.py -r bigbuckbunny -n /edu/umass/BigBuckBunny_2s.mpd<br/>
### @ Client host
cd /users/ishitadg/ndn-python-repo/examples/;<br/>
python3 getfile.py -r bigbuckbunny -n /edu/umass/bunny_595491bps/bunny_595491bps_BigBuckBunny_2s299.m4s<br/>
### @ From inside a single Docker client
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnpyrepo_install.sh;<br/>
bash ndnpyrepo_install.sh;<br/>
cd ndn-python-repo/examples/;<br/>
python3 getfile.py -r bigbuckbunny -n /edu/umass/BigBuckBunny_2s.mpd<br/>
python3 getfile.py -r bigbuckbunny -n /edu/umass/bunny_791182bps/bunny_791182bps_BigBuckBunny_2s299.m4s<br/>


## STEP 7: REPORT QoE 
### @ NDN CLIENT
#### BEFORE running ndnclients
rm out*; rm *.mpd; rm trace*;<br/>
bash ndnlive.sh;<br/>
bash ndnqoe.sh;<br/>
#### AFTER running ndnclients
for (( i=0; i<20; i++ )); do docker cp ndn$i:AStream/dist/client/BigBuckBunny_2s.mpd BB$i.mpd; done <br/>
for (( i=0; i<20; i++ )); do docker cp ndn$i:AStream/dist/client/out.txt out$i.txt; done<br/>
for (( i=0; i<20; i++ )); do docker cp ndn$i:tcpdump.pcap tcp$i.pcap; done<br/>
### @ IP CLIENT
cd /users/ishitadg/AStream/dist/client;<br/>
bash ipod.sh <br/>
bash ipodqoe.sh <br/>
python sample.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola <br/>


# ***IGNORE**** OLDER VERSION INSTRUCTIONS earlier UBUNTU versions ***IGNORE****
## STEP1: Server & client setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn.sh <br/>
bash 1_ndn.sh <br/>
### Additional step at server: (install vim,tmux,BB video files,apache2)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_server.sh <br/>
bash 1_server.sh <br/>
*OR* <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_serverdld.sh <br/>
bash 1_serverdld.sh <br/>
### Additional step at client: (run Dockerfile, download client, Astreamer)
#### DOCKER - KERNEL VERSION ISSUE (ONLY FOR NDN CLIENT):
apt-get update <br/>
sudo apt-get install --install-recommends linux-generic-lts-xenial <br/>
dpkg -l | grep linux-image <br/>
sudo apt-get update; reboot <br/>
Uname -r <br/>
Kernel updated to 4.4.0-142-generic !!!!<br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndnc.sh <br/>
bash 1_ndnc.sh <br/>
#### FOR IP CLIENT
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ipclient.sh <br/>
bash 1_ipclient.sh <br/>

## STEP 2: Controller setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/2_ryu.sh <br/>
bash 2_ryu.sh <br/>
cd ryu/ <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/controllerhalfbig.py <br/>
ryu-manager controller.py <br/>
(print dpid and modify line 66 accordingly) <br/>
(Run controller again) <br/>
## Step 3: Bridge setup on Routers:
### INSTALL & START VMs
follow 3_vmsetup.sh <br/>

!!Update Routes!!  <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.2.4; <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.3.4; <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.4.4; <br/>


## Step 4: Streaming & QoE calcualtion over IP / NDN / IP+NDN
@router:<br/>
nfd-stop;nfd-start; nfdc register ndn:/edu/umass 257<br/>
@client:<br/>
nfd-stop;nfd-start; nfdc route add prefix /edu/umass nexthop 257;

@server:
nfd-stop;nfd-start;<br/>
./ndnperfserver -p ndn:/edu/umass -c 1500 -f 3600000<br/>

TEST WITH:<br/>
"./ndnperf -p ndn:/edu/umass -d www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -w 16"<br/>
"wget http://10.10.1.1/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd"<br/>


##### Streaming over IP & NDN ####
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipndn.sh;
bash ipndn.sh;



### IP+NDN
#### IP on-demand+ NDN live
TO KILL ALL CONTAINERS <br/>
docker kill $(docker ps -q)  <br/>
@client1 IP ondemand: <br/>
cd /users/ishitadg/AStream/dist/client;<br/>
bash ipod.sh <br/>
bash ipodqoe.sh <br/>

@client2 NDN LIVE: <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/setupdockersimple.sh <br/>

bash startdockers.sh <br/>
#### NDN only MPD tests for interrupted downloads
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_onlympd.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/nfd.conf <br/>
for (( i=0; i<10; i++ )); do docker cp dash_client_onlympd.py ndn$i:AStream/dist/client/; docker cp nfd.conf ndn$i:/usr/local/etc/ndn/nfd.conf; done <br/>

bash setupdockers.sh <br/>

bash setupdockersimple.sh <br/>
bash pingtest.sh <br/>
bash ndnlive.sh <br/>
bash ndnqoe.sh <br/>

scp -r ishitadg@c220g1-030809.wisc.cloudlab.us:IP ~/ResearchZink/ndn-results/linetopo/IPNDN/;<br/>
scp -r ishitadg@c220g1-030809.wisc.cloudlab.us:NDN ~/ResearchZink/ndn-results/linetopo/IPNDN/;<br/>
#### NDN only MPD tests for interrupted downloads
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_onlympd.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/nfd.conf <br/>
ifconfig docker0 down;<br/>
##### BEFORE running ndnclients
rm out*;rm *.mpd; rm trace*;<br/>
for (( i=0; i<20; i++ )); do docker cp dash_client_onlympd.py ndn$i:AStream/dist/client/; docker cp nfd.conf ndn$i:/usr/local/etc/ndn/nfd.conf; done<br/>
##### AFTER running ndnclients
for (( i=0; i<20; i++ )); do docker cp ndn$i:AStream/dist/client/BigBuckBunny_2s.mpd BB$i.mpd; done <br/>
for (( i=0; i<20; i++ )); do docker cp ndn$i:AStream/dist/client/out.txt out$i.txt; done<br/>
for (( i=0; i<20; i++ )); do docker cp ndn$i:tcpdump.pcap tcp$i.pcap; done<br/>

python sample.py -m /www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/BigBuckBunny_2s.mpd -p bola <br/>

### IP+IP
#### IP on-demand+ IP live
@client1 IP ondemand: <br/>
cd /users/ishitadg/AStream/dist/client;<br/>
rm dash_client_od.py;<br/>
rm configure_log_file.py;<br/>
rm config_dash.py;<br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/configure_log_file.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_od.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/config_dash.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipod.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipodqoe.sh <br/>
bash ipod.sh <br/>
bash ipodqoe.sh <br/>

@client2 IP LIVE: <br/>
cd /users/ishitadg; <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/iplive.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/iplqoe.sh <br/>
bash iplive.sh <br/>
bash iplqoe.sh <br/>

scp -r ishitadg@c220g1-030809.wisc.cloudlab.us:IP ~/ResearchZink/ndn-results/linetopo/IPIP/;
scp -r ishitadg@c220g1-030809.wisc.cloudlab.us:IPL ~/ResearchZink/ndn-results/linetopo/IPIP/;

### NDN+NDN
#### NDN on-demand+ NDN live
@client1 NDN ondemand: <br/>
cd /users/ishitadg/AStream/dist/client;<br/>
rm dash_client_udpDod.py;<br/>
rm configure_log_file.py;<br/>
rm config_dash.py;<br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/configure_log_file.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/config_dash.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_udpDod.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnod.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnodqoe.sh <br/>
bash ndnod.sh <br/>
bash ndnodqoe.sh <br/>

@client2 NDN LIVE: <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnlive.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnliveqoe.sh <br/>
bash ndnlive.sh <br/>
bash ndnliveqoe.sh <br/>

scp -r ishitadg@c220g1-030809.wisc.cloudlab.us:NDNO ~/ResearchZink/ndn-results/linetopo/NDNDN/;
scp -r ishitadg@c220g1-030809.wisc.cloudlab.us:NDN ~/ResearchZink/ndn-results/linetopo/NDNDN/;

## Others: Save updated IPvM , NDNvM, (Docker, Client, server image TBD)
scp -r ishitadg@pc463.emulab.net:ipvm.qcow2 ~/ResearchZink/
scp -r ishitadg@pc463.emulab.net:ndnvm.qcow2 ~/ResearchZink/

