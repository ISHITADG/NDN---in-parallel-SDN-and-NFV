# NDN---in-parallel-SDN-and-NFV
# An Evaluation of SDN and NFV Support for Parallel, Alternative Protocol Stack Operations on CloudLab

## STEP1: Server & client setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn.sh
bash 1_ndn.sh
### Additional step at server: (install vim,tmux,BB video files,apache2)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_server.sh
bash 1_server.sh
### Additional step at client: (run Dockerfile, download client, Astreamer)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_client.sh
bash 1_client.sh

## STEP 2: Controller setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/2_ryu.sh
bash 2_ryu.sh
cd ryu/
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/controller.py
ryu-manager controller.py
### (print dpid and modify line 66 accordingly)
### Run controller again

## Step 3: Bridge setup on Routers:
### INSTALL & START VMs
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/3_vmsetup.sh
bash 3_vmsetup.sh
virsh console ndnVM
ipVM login: mzink
Password: test
sudo ovs-vsctl set bridge ovsbr0 protocols=OpenFlow10,OpenFlow13
