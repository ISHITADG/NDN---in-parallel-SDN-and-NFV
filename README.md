# NDN---in-parallel-SDN-and-NFV
# An Evaluation of SDN and NFV Support for Parallel, Alternative Protocol Stack Operations on CloudLab
## Server & client:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn.sh </br>
bash 1_ndn.sh
### Additional step at server: 
wget -r --no-parent --reject \"index.html*\" http://www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/
### Additional step at client:


## Controller:
</br>wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/2_ryu.sh
</br>bash 2_ryu.sh
</br>cd ryu/
</br>wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/controller.py
</br>sudo pip install six --upgrade
</br>ryu-manager controller.py

## Routers:
### Install & start VMs
</br>wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/3_vmsetup.sh
</br>bash 3_vmsetup.sh
### Connect to controller
</br>sudo apt-get update
</br>ovs-vsctl get-controller ovsbr0
</br>ovs-vsctl list-ifaces ovsbr0
</br>ovs-vsctl show 
</br>ovs-ofctl show ovsbr0 
### (gives same result as doing this): ovs-vsctl get Bridge ovsbr0 datapath-id
### On controller-end: manipulated the code to print dpid: (got this instead)
</br>191445057984326

