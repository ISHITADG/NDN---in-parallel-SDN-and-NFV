##Run this first: This installs all the dependencies
#!/bin/bash
sudo apt-get update
sudo apt-get -y install vim
sudo apt-get purge libvirt-bin
sudo apt-get -y install libvirt-bin
sudo apt-get -y install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
sudo virsh connect qemu:///system
sudo brctl addbr virbr1
sudo brctl addbr virbr2
sudo brctl stp virbr1 on
sudo brctl stp virbr2 on

#Run this second: Recreates the ovs bridge and linux bridges
sudo ovs-vsctl add-br ovsbr0
sudo ifconfig virbr0 down
sudo brctl delbr virbr0
sudo brctl addbr virbr0
sudo brctl addif virbr0 vnet1
sudo ovs-vsctl add-port ovsbr0 virbr0
sudo brctl stp virbr0 on
sudo ifconfig virbr0 up
sudo ovs-vsctl set-controller ovsbr0 tcp:<IP for controller>:6633

#instantiate VMs
wget 'http://emmy10.casa.umass.edu/CNP/ipVM.qcow2'
wget -L 'https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipVM.xml'
wget 'http://emmy10.casa.umass.edu/CNP/ndnVM.qcow2'
wget -L 'https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnVM.xml'
sudo virsh define ipVM.xml
sudo virsh define ndnVM.xml
sudo virsh start ipVM
sudo virsh start ndnVM
cd /tmp
sudo virsh dumpxml ndnVM > ndnVM.xml
sudo virsh dumpxml ipVM > ipVM.xml
cd ~
