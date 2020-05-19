##Run this first: This installs all the dependencies
#!/bin/bash
sudo apt-get update
sudo apt-get -y install vim && sudo apt-get purge libvirt-bin
sudo apt-get -y install libvirt-bin
sudo apt-get -y install qemu-kvm ubuntu-vm-builder bridge-utils && sudo virsh connect qemu:///system
git clone https://github.com/esnet/iperf.git;
cd iperf && ./configure && make && make install;
ldconfig;
iperf3 -v;
cd ..;

#new installations
sudo apt-get update
sudo apt-get install -y openvswitch-switch
sudo /etc/init.d/openvswitch-switch start 
ovs-vsctl --version

#Run this second: add physical interfaces to eth without OVS bridge copying it
sudo su 
ovs-vsctl del-br ovsbr0
ovs-vsctl add-br ovsbr0
ovs-vsctl add-port ovsbr0 eth1
ovs-vsctl add-port ovsbr0 eth2
ovs-vsctl add-port ovsbr0 eth4
#ovs-vsctl add-port ovsbr0 eth3
#ovs-vsctl set Bridge ovsbr0 other_config:hwaddr="42:f6:4a:97:92:46"
ovs-vsctl set Bridge ovsbr0 other_config:hwaddr="1e:70:f6:a4:0a:48"
ovs-vsctl set-controller ovsbr0 tcp:155.98.39.152:6633

#test with
ovs-ofctl dump-ports-desc ovsbr0
#ovs-appctl fdb/show ovsbr0
#ovs-ofctl dump-flows ovsbr0

#creating virtual interface and adding to ovs-bridge (http://www.pocketnix.org/posts/Linux%20Networking:%20Dummy%20Interfaces%20and%20Virtual%20Bridges)
ip link del virbr1
ip link del virbr2
ovs-vsctl del-port ovsbr0 virbr1
ovs-vsctl del-port ovsbr0 virbr2
ip link add name virbr1 type bridge
ip link add name virbr2 type bridge
ip link add name virbr3 type bridge
ip link add name virbr4 type bridge
ip link add name virbr5 type bridge
ip link add name virbr6 type bridge
ip link add name virbr7 type bridge
ip link add name virbr8 type bridge
ip link set virbr1 up
ip link set virbr2 up
ip link set virbr3 up
ip link set virbr4 up
ip link set virbr5 up
ip link set virbr6 up
ip link set virbr7 up
ip link set virbr8 up
ovs-vsctl add-port ovsbr0 virbr1
ovs-vsctl add-port ovsbr0 virbr2
ovs-vsctl add-port ovsbr0 virbr3
ovs-vsctl add-port ovsbr0 virbr4
ovs-vsctl add-port ovsbr0 virbr5
ovs-vsctl add-port ovsbr0 virbr6
ovs-vsctl add-port ovsbr0 virbr7
ovs-vsctl add-port ovsbr0 virbr8

#instantiate VMs
wget 'http://emmy10.casa.umass.edu/CNP/ishita/ipVM.qcow2'
wget -L 'https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipVM.xml'
wget 'http://emmy10.casa.umass.edu/CNP/ishita/ndnVM.qcow2'
wget -L 'https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnVM.xml'
sudo virsh define ipVM.xml
sudo virsh define ndnVM.xml
sudo virsh start ipVM
sudo virsh start ndnVM
