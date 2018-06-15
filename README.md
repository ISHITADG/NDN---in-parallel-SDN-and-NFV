# NDN---in-parallel-SDN-and-NFV
# An Evaluation of SDN and NFV Support for Parallel, Alternative Protocol Stack Operations on CloudLab
## Server & client:
<br> wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn.sh </br>
<br> bash 1_ndn.sh </br>
### Additional step at server: 
wget -r --no-parent --reject \"index.html*\" http://www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
### Additional step at client:


## Controller:
>wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/2_ryu.sh
>bash 2_ryu.sh
cd ryu/
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/controller.py
sudo pip install six --upgrade
ryu-manager controller.py

## Routers:
### INSTALL & START VMs
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/3_vmsetup.sh
bash 3_vmsetup.sh
### CONNECT TO CONTROLLER
Sudo apt-get update
ovs-vsctl get-controller ovsbr0
ovs-vsctl list-ifaces ovsbr0
ovs-vsctl show 
ovs-ofctl show ovsbr0 
### (gives same result as doing this): ovs-vsctl get Bridge ovsbr0 datapath-id
### On controller-end: manipulated the code to print dpid: (got this instead)
191445057984326

