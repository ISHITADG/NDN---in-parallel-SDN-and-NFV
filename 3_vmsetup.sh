##Run this first: This installs all the dependencies
#!/bin/bash
sudo apt-get update
sudo apt-get install vim
sudo apt-get purge libvirt-bin
sudo apt-get install libvirt-bin
sudo apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
sudo virsh connect qemu:///system
sudo brctl addbr virbr1
sudo brctl addbr virbr2
sudo brctl addbr virbr3
sudo brctl stp virbr1 on
sudo brctl stp virbr2 on
sudo brctl stp virbr3 on 

cd /tmp
virsh dumpxml ndnVM > ndnVM.xml
virsh dumpxml ipVM > ipVM.xml

#Run this second: Recreates the ovs bridge and linux bridges
sudo ovs-vsctl del-br ovsbr0
sudo ovs-vsctl add-br ovsbr0
sudo ifconfig virbr0 down
sudo ifconfig virbr1 down
sudo ifconfig virbr2 down
sudo ifconfig virbr3 down
sudo brctl delbr virbr0
sudo brctl delbr virbr1
sudo brctl delbr virbr2
sudo brctl delbr virbr3
sudo brctl addbr virbr0
sudo brctl addbr virbr1
sudo brctl addbr virbr2
sudo brctl addbr virbr3
sudo ifconfig virbr0 down
sudo ifconfig virbr1 down
sudo ifconfig virbr2 down
sudo ifconfig virbr3 down
sudo brctl addif virbr1 vnet1
sudo brctl addif virbr2 vnet2
sudo brctl addif virbr3 vnet3
sudo ovs-vsctl add-port ovsbr0 virbr1
sudo ovs-vsctl add-port ovsbr0 virbr2
sudo ovs-vsctl add-port ovsbr0 virbr3
sudo ovs-vsctl set-controller ovsbr0 tcp:128.104.222.68:6633

#instantiate VMs
wget 'http://emmy10.casa.umass.edu/CNP/ipVM.qcow2'
wget 'https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipVM.xml'
wget 'http://emmy10.casa.umass.edu/CNP/ndnVM.qcow2'
wget 'https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnVM.xml'
virsh define ipVM.xml
virsh define ndnVM.xml
virsh start ipVM
virsh start ndnVM
