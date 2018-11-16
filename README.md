# NDN---in-parallel-SDN-and-NFV
# An Evaluation of SDN and NFV Support for Parallel, Alternative Protocol Stack Operations on CloudLab

## STEP1: Server & client setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn.sh <br/>
bash 1_ndn.sh <br/>
### Additional step at server: (install vim,tmux,BB video files,apache2)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_server.sh <br/>
bash 1_server.sh <br/>
### Additional step at client: (run Dockerfile, download client, Astreamer)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_client.sh <br/>
bash 1_client.sh <br/>

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
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/3_vmsetup.sh <br/>
bash 3_vmsetup.sh <br/>
virsh console ndnVM<br/>
ipVM login: mzink<br/>
Password: test<br/>
sudo ovs-vsctl set bridge ovsbr0 protocols=OpenFlow10,OpenFlow13<br/>
