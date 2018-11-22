# NDN---in-parallel-SDN-and-NFV
# An Evaluation of SDN and NFV Support for Parallel, Alternative Protocol Stack Operations on CloudLab

## STEP1: Server & client setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn.sh <br/>
bash 1_ndn.sh <br/>
### Additional step at server: (install vim,tmux,BB video files,apache2)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_server.sh <br/>
bash 1_server.sh <br/>
### Additional step at client: (run Dockerfile, download client, Astreamer)
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_client.sh <br/>
bash 1_client.sh <br/>

## STEP 2: Controller setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/2_ryu.sh <br/>
bash 2_ryu.sh <br/>
cd ryu/ <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/controller.py <br/>
ryu-manager controller.py <br/>
(print dpid and modify line 66 accordingly) <br/>
(Run controller again) <br/>

## Step 3: Bridge setup on Routers:
### INSTALL & START VMs
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/3_vmsetup.sh <br/>
bash 3_vmsetup.sh <br/>
virsh console ndnVM<br/>
ipVM login: mzink<br/>
Password: test<br/>
sudo ovs-vsctl set bridge ovsbr0 protocols=OpenFlow10,OpenFlow13<br/>

## Step 4: Create and initialise an ubuntu VM from scratch

echo ' <network>
		<name>vmbr0</name>
		<forward mode="route"/>
		<bridge name="vmbr0" stp="on" delay="0"/>
		<ip address="10.10.3.1" netmask="255.255.255.252">
			<dhcp>
				<range start="10.10.3.2" end="10.10.3.3"/>
			</dhcp>
		</ip>
	</network>' >> network.xml

  virsh net-define network.xml
  virsh net-autostart vmbr0

  virsh net-destroy default
  virsh net-undefine default
  service libvirt-bin restart
  sed -i "/net.ipv4.ip_forward=1/ s/# *//" /etc/sysctl.conf

sudo vmbuilder kvm ubuntu     --suite trusty     --flavour virtual     --addpkg=linux-image-generic     --addpkg=unattended-upgrades     --addpkg openssh-server     --addpkg=acpid     --arch amd64     --libvirt qemu:///system     --user ishita     --name ishita     --hostname=ishita     --pass ishita --ip 192.168.0.12 --mask 255.255.255.0 --net 192.168.0.0 --bcast 192.168.0.255 --gw 192.168.0.1 --dns 192.168.0.1

sudo ubuntu-vm-builder kvm trusty --domain icnMZ --dest icnMZ --hostname ndnvm --user mzink --pass test --addpkg acpid --addpkg vim --addpkg openssh-server --addpkg linux-image-generic --libvirt qemu:///system -d /users/ishitadg/ubuntu-kvm

virsh start <hostname>
