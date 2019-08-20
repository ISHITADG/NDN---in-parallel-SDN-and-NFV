# NDN---in-parallel-SDN-and-NFV
# An Evaluation of SDN and NFV Support for Parallel, Alternative Protocol Stack Operations on CloudLab




## STEP1: Server & client setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn.sh <br/>
bash 1_ndn.sh <br/>
### Additional step at server: (install vim,tmux,BB video files,apache2)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_server.sh <br/>
bash 1_server.sh <br/>
*OR* <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_serverdld.sh <br/>
bash 1_serverdld.sh <br/>
!!**route update for server**!!  <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.1.4; <br/>
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
!!**route update for clients**!!  <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.2.4; <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.3.4; <br/>

## STEP 2: Controller setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/2_ryu.sh <br/>
bash 2_ryu.sh <br/>
cd ryu/ <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/controller.py <br/>
ryu-manager controller.py <br/>
(print dpid and modify line 66 accordingly) <br/>
(Run controller again) <br/>
 

## Step 3: Bridge setup on Routers:
### INSTALL & START VMs
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/3_vm3.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/3_vm3.sh <br/>
bash 3_vm3.sh <br/>
bash 3_vm4.sh <br/>
virsh console ndnVM<br/>
ipVM login: mzink<br/>
Password: test<br/>
ovs-ofctl dump-ports-desc ovsbr0<br/>
ovs-ofctl dump-flows ovsbr0<br/>
sudo ovs-vsctl set bridge ovsbr0 protocols=OpenFlow10,OpenFlow13<br/>

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

@client2 NDN LIVE: <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/startdockers.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/setupdockers.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/setupdockersimple.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/pingtest.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnlive.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnliveqoe.sh <br/>

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
for (( i=0; i<10; i++ )); do docker cp dash_client_onlympd.py ndn$i:AStream/dist/client/; done<br/>

for (( i=0; i<10; i++ )); do docker cp ndn$i:AStream/dist/client/BigBuckBunny_2s.mpd BB$i.mpd; done
<br/>



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

