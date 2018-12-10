##Run this first: This installs all the dependencies
#!/bin/bash
sudo apt-get update
sudo apt-get -y install vim
sudo apt-get purge libvirt-bin
sudo apt-get -y install libvirt-bin
sudo apt-get -y install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
sudo virsh connect qemu:///system

#Run this second: add physical interfaces to eth without OVS bridge copying it
sudo su 
ovs-vsctl add-br ovsbr0
ovs-vsctl add-port ovsbr0 eth1
ovs-vsctl add-port ovsbr0 eth3
ovs-vsctl set Bridge ovsbr0 other_config:hwaddr="0a:c2:f9:c0:b6:49"
ovs-vsctl set-controller ovsbr0 tcp:128.104.222.95:6633

#test with
ovs-ofctl dump-ports-desc ovsbr0
ovs-appctl fdb/show ovsbr0
ovs-ofctl dump-flows ovsbr0

#creating virtual interface and adding to ovs-bridge (http://www.pocketnix.org/posts/Linux%20Networking:%20Dummy%20Interfaces%20and%20Virtual%20Bridges)
ip link del virbr1
ip link del virbr2
ovs-vsctl del-port ovsbr0 virbr1
ovs-vsctl del-port ovsbr0 virbr2
ip link add name virbr1 type bridge
ip link add name virbr2 type bridge
ip link set virbr1 up
ip link set virbr2 up
ovs-vsctl add-port ovsbr0 virbr1
ovs-vsctl add-port ovsbr0 virbr2

#made changes in ndnVM --added eth1,eth2 for the VM with MAC addresses of virbr1,virbr2 and then ifconfig up inside the VM

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
