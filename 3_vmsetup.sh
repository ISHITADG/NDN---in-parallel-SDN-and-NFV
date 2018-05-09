##Run this first: This installs all the dependencies
#!/bin/bash
sudo apt-get update
sudo apt-get install vim
sudo apt-get purge libvirt-bin
sudo apt-get install libvirt-bin
sudo apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
virsh connect qemu:///system
brctl addbr virbr1
brctl addbr virbr2
brctl addbr virbr3
cd /tmp
virsh dumpxml ndnVM > ndnVM.xml
virsh dumpxml ipVM > ipVM.xml

#Run this second: Recreates the ovs bridge and linux bridges
ovs-vsctl del-br ovsbr0
ovs-vsctl add-br ovsbr0
ifconfig virbr0 down
ifconfig virbr1 down
ifconfig virbr2 down
ifconfig virbr3 down
brctl delbr virbr0
brctl delbr virbr1
brctl delbr virbr2
brctl delbr virbr3
brctl addbr virbr0
brctl addbr virbr1
brctl addbr virbr2
brctl addbr virbr3
ifconfig virbr0 down
ifconfig virbr1 down
ifconfig virbr2 down
ifconfig virbr3 down
brctl addif virbr1 vnet1
brctl addif virbr2 vnet2
brctl addif virbr3 vnet3
ovs-vsctl add-port ovsbr0 virbr1
ovs-vsctl add-port ovsbr0 virbr2
ovs-vsctl add-port ovsbr0 virbr3
ovs-vsctl set-controller ovsbr0 tcp:**ip address of the controller**:6633
