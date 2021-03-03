##Run this first: This installs all the dependencies
#!/bin/bash
sudo apt-get update;
sudo apt-get -y install vim && sudo apt-get purge libvirt-bin;
sudo apt-get -y install libvirt-bin;
sudo apt-get -y install qemu-kvm ubuntu-vm-builder bridge-utils && sudo virsh connect qemu:///system;
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/qemu.conf;
mv qemu.conf /etc/libvirt/qemu.conf;
service libvirtd restart;
git clone https://github.com/esnet/iperf.git;
cd iperf && ./configure && make && make install;
ldconfig;
iperf3 -v;
cd ..;

#new installations
sudo apt-get update;
sudo apt-get install -y openvswitch-switch;
sudo /etc/init.d/openvswitch-switch start;
ovs-vsctl --version;

#Run this second: add physical interfaces to eth without OVS bridge copying it
ovs-vsctl del-br ovsbr0;
ovs-vsctl add-br ovsbr0;
ifconfig ovsbr0 up;
ovsadd=$(cat /sys/class/net/ovsbr0/address);

echo "enter ethernet ports in order: " 
read e1 e2 e3 e4
#eno2 eno4 enp5s0f0 enp5s0f1
ovs-vsctl add-port ovsbr0 $e1
ovs-vsctl add-port ovsbr0 $e2
ovs-vsctl add-port ovsbr0 $e3
ovs-vsctl add-port ovsbr0 $e4
ovs-vsctl set Bridge ovsbr0 other_config:hwaddr=$ovsadd
echo "IP address of SDN controller: "
read sdnip
#155.98.38.126
ovs-vsctl set-controller ovsbr0 tcp:$sdnip:6633

#test with
ovs-ofctl dump-ports-desc ovsbr0
ovs-ofctl dump-flows ovsbr0

#creating virtual interface and adding to ovs-bridge (http://www.pocketnix.org/posts/Linux%20Networking:%20Dummy%20Interfaces%20and%20Virtual%20Bridges)
ip link del virbr1
ip link del virbr2
ip link del virbr3
ip link del virbr4
ip link del virbr5
ip link del virbr6
ip link del virbr7
ip link del virbr8
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
cp -r /proj/CDNABRTest/ipVM.xml .
cp -r /proj/CDNABRTest/ndnIP.xml .

#modify ipvm.xml & ndnvm.xml
MYCUSTOMTAB='      '
v1=$(cat /sys/class/net/virbr1/address)
v2=$(cat /sys/class/net/virbr2/address)
v3=$(cat /sys/class/net/virbr3/address)
v4=$(cat /sys/class/net/virbr4/address)
v5=$(cat /sys/class/net/virbr5/address)
v6=$(cat /sys/class/net/virbr6/address)
v7=$(cat /sys/class/net/virbr7/address)
v8=$(cat /sys/class/net/virbr8/address)
lineo=${MYCUSTOMTAB}"<mac address='$ovsadd'/>"
line1=${MYCUSTOMTAB}"<mac address='$v1'/>"
line2=${MYCUSTOMTAB}"<mac address='$v2'/>"
line3=${MYCUSTOMTAB}"<mac address='$v3'/>"
line4=${MYCUSTOMTAB}"<mac address='$v4'/>"
line5=${MYCUSTOMTAB}"<mac address='$v5'/>"
line6=${MYCUSTOMTAB}"<mac address='$v6'/>"
line7=${MYCUSTOMTAB}"<mac address='$v7'/>"
line8=${MYCUSTOMTAB}"<mac address='$v8'/>"
#R1
sed -i "91s|.*|$lineo|g" ndnr1vm.xml
sed -i "100s|.*|$line1|g" ndnr1vm.xml
sed -i "106s|.*|$line2|g" ndnr1vm.xml
sed -i "112s|.*|$line3|g" ndnr1vm.xml
sed -i "91s|.*|$lineo|g" ipr1vm.xml
sed -i "100s|.*|$line4|g" ipr1vm.xml
sed -i "106s|.*|$line5|g" ipr1vm.xml
sed -i "112s|.*|$line6|g" ipr1vm.xml
#R2
sed -i "91s|.*|$lineo|g" ndnr2vm.xml
sed -i "100s|.*|$line1|g" ndnr2vm.xml
sed -i "106s|.*|$line2|g" ndnr2vm.xml
sed -i "112s|.*|$line3|g" ndnr2vm.xml
sed -i "118s|.*|$line4|g" ndnr2vm.xml
sed -i "91s|.*|$lineo|g" ipr2vm.xml
sed -i "100s|.*|$line5|g" ipr2vm.xml
sed -i "106s|.*|$line6|g" ipr2vm.xml
sed -i "112s|.*|$line7|g" ipr2vm.xml
sed -i "118s|.*|$line8|g" ipr2vm.xml
#R3
sed -i "91s|.*|$lineo|g" ndnr3vm.xml
sed -i "100s|.*|$line1|g" ndnr3vm.xml
sed -i "106s|.*|$line2|g" ndnr3vm.xml
sed -i "112s|.*|$line3|g" ndnr3vm.xml
sed -i "118s|.*|$line4|g" ndnr3vm.xml
sed -i "91s|.*|$lineo|g" ipr3vm.xml
sed -i "100s|.*|$line5|g" ipr3vm.xml
sed -i "106s|.*|$line6|g" ipr3vm.xml
sed -i "112s|.*|$line7|g" ipr3vm.xml
sed -i "118s|.*|$line8|g" ipr3vm.xml

#start vms
virsh define ndnr1vm.xml
virsh define ndnr2vm.xml
virsh define ndnr3vm.xml
virsh define ipr1vm.xml
virsh define ipr2vm.xml
virsh define ipr3vm.xml
virsh start ipr1vm
virsh start ipr2vm
virsh start ipr3vm
virsh start ndnr1vm
virsh start ndnr2vm
virsh start ndnr3vm
echo done
