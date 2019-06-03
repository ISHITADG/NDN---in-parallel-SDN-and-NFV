#For VM with 3 interfaces
#!/bin/bash
sudo apt-get update
sudo apt-get -y install vim
sudo apt-get purge libvirt-bin
sudo apt-get -y install libvirt-bin
sudo apt-get -y install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
sudo virsh connect qemu:///system
git clone https://github.com/esnet/iperf.git;
cd iperf;
./configure;
make;
make install;
ldconfig;
iperf3 -v;

#OVS-setup
ovs-vsctl del-br ovsbr0
ovs-vsctl add-br ovsbr0
ovs=$(ifconfig ovsbr0 | grep -Po 'HWaddr \K.*$')
#edit this before running
ovs-vsctl add-port ovsbr0 eth1
ovs-vsctl add-port ovsbr0 eth2
ovs-vsctl add-port ovsbr0 eth4
ovs-vsctl set Bridge ovsbr0 other_config:hwaddr=$ovs
ovs-vsctl set-controller ovsbr0 tcp:155.98.39.155:6633

#add virtual network
ip link add name virbr1 type bridge
ip link add name virbr2 type bridge
ip link add name virbr3 type bridge
ip link add name virbr4 type bridge
ip link add name virbr5 type bridge
ip link add name virbr6 type bridge
ip link set virbr1 up
ip link set virbr2 up
ip link set virbr3 up
ip link set virbr4 up
ip link set virbr5 up
ip link set virbr6 up
ovs-vsctl add-port ovsbr0 virbr1
ovs-vsctl add-port ovsbr0 virbr2
ovs-vsctl add-port ovsbr0 virbr3
ovs-vsctl add-port ovsbr0 virbr4
ovs-vsctl add-port ovsbr0 virbr5
ovs-vsctl add-port ovsbr0 virbr6

wget 'http://emmy10.casa.umass.edu/CNP/ishita/ipVM.qcow2'
wget -L 'https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipVM.xml'
wget 'http://emmy10.casa.umass.edu/CNP/ishita/ndnVM.qcow2'
wget -L 'https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnVM.xml'
v1=$(ifconfig virbr1 | grep -Po 'HWaddr \K.*$')
v2=$(ifconfig virbr2 | grep -Po 'HWaddr \K.*$')
v3=$(ifconfig virbr3 | grep -Po 'HWaddr \K.*$')
v4=$(ifconfig virbr4 | grep -Po 'HWaddr \K.*$')
v5=$(ifconfig virbr5 | grep -Po 'HWaddr \K.*$')
v6=$(ifconfig virbr6 | grep -Po 'HWaddr \K.*$')

#edit ndnVM.xml
sed -i '30s/.*/"<mac address="$ovs"/>"/' ndnVM.xml
sed -i '39s/.*/"<mac address="$v1"/>"/' ndnVM.xml
sed -i '45s/.*/"<mac address="$v2"/>"/' ndnVM.xml
sed -i '51s/.*/"<mac address="$v3"/>"/' ndnVM.xml
#edit ipVM.xml
sed -i '34s/.*/"<mac address="$ovs"/>"/' ipVM.xml
sed -i '43s/.*/"<mac address="$v4"/>"/' ipVM.xml
sed -i '49s/.*/"<mac address="$v5"/>"/' ipVM.xml
sed -i '55s/.*/"<mac address="$v6"/>"/' ipVM.xml
