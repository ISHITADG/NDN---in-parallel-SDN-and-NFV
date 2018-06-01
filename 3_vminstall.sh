##Run this first: This installs all the dependencies
#!/bin/bash
sudo apt-get update
sudo apt-get install vim
sudo apt-get purge libvirt-bin
sudo apt-get install libvirt-bin
sudo apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
echo done
