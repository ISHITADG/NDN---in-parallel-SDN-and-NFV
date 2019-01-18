# NDN---in-parallel-SDN-and-NFV
# An Evaluation of SDN and NFV Support for Parallel, Alternative Protocol Stack Operations on CloudLab

## STEP1: Server & client setup:
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/1_ndn.sh <br/>
bash 1_ndn.sh <br/>
!!**routes to clien**t!!  <br/>
sudo route del -net 10.0.0.0 netmask 255.0.0.0;  <br/>
sudo ip route add 10.0.0.0/8 via 10.10.2.4; <br/>
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

## Step 4: Streaming & QoE calcualtion over IP / NDN / IP+NDN:
### IP+NDN
#### IP on-demand+ NDN live
@client1: <br/>
cd /users/ishitadg/AStream/dist/client;<br/>
rm dash_client.py;<br/>
rm dash_client_od.py;<br/>
rm configure_log_file.py;<br/>
rm config_dash.py;<br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/configure_log_file.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client_od.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/config_dash.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/dash_client.py <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipodndnlive.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ipndnqoe.sh <br/>
bash ipodndnlive.sh <br/>
bash ipndnqoe.sh <br/>

@client2(virbr1): <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnlive.sh <br/>
wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/ndnqoe.sh <br/>
bash ndnlive.sh <br/>
bash ndnqoe.sh <br/>

scp -r ishitadg@c220g1-030809.wisc.cloudlab.us:IP ~/ResearchZink/ndn-results/IPNDN/;
scp -r ishitadg@c220g1-030809.wisc.cloudlab.us:NDN ~/ResearchZink/ndn-results/IPNDN/;

### IP+IP
#### IP on-demand+ IP live


### NDN+NDN
#### NDN on-demand+ NDN live

## Others: Create and initialise an ubuntu VM from scratch

sudo su<br/>
ifconfig eth1 up<br/>
ifconfig eth2 up<br/>
vim /etc/network/interfaces<br/> 
/etc/init.d/networking restart
echo ' <network>
		<name>ip</name>
		<forward mode="route"/>
		<bridge name="virbr1" stp="on" delay="0"/>
		<ip address="10.10.2.4" netmask="255.255.255.0">
		</ip>
	        <bridge name="virbr2" stp="on" delay="0"/>
		<ip address="10.10.1.4" netmask="255.255.255.0">
		</ip>
	</network>' >> ip.xml
reboot
echo ' <network>
		<name>ip</name>
		<forward mode="route"/>
		<bridge name="virbr1" stp="on" delay="0"/>
		<ip address="10.10.2.4" netmask="255.255.255.0">
		</ip>
	        <bridge name="virbr2" stp="on" delay="0"/>
		<ip address="10.10.1.4" netmask="255.255.255.0">
		</ip>
	</network>' >> ip.xml

  virsh net-define network.xml
  virsh net-autostart vmbr0

  virsh net-destroy default
  virsh net-undefine default
  service libvirt-bin restart
  sed -i "/net.ipv4.ip_forward=1/ s/# *//" /etc/sysctl.conf

sudo vmbuilder kvm ubuntu     --suite trusty     --flavour virtual     --addpkg=linux-image-generic     --addpkg=unattended-upgrades     --addpkg openssh-server     --addpkg=acpid     --arch amd64     --libvirt qemu:///system     --user ishita     --name ishita     --hostname=ishita     --pass ishita --ip 192.168.0.12 --mask 255.255.255.0 --net 192.168.0.0 --bcast 192.168.0.255 --gw 192.168.0.1 --dns 192.168.0.1

sudo ubuntu-vm-builder kvm trusty --domain icnMZ --dest icnMZ --hostname ndnvm --user mzink --pass test --addpkg acpid --addpkg vim --addpkg openssh-server --addpkg linux-image-generic --libvirt qemu:///system -d /users/ishitadg/ubuntu-kvm

virsh start <hostname>
