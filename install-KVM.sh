#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
set_subnet=192.168.100
set_netmask=255.255.255.0
system_eth=eth0 
system_ip=4
bridged_eth=eth1
bridged_ip=5
gateway_ip=1
server_arch=$(dpkg --print-architecture)

function install_packages ()
{
# update system
sudo apt-get update 
sudo apt-get dist-upgrade -y
sudo apt-get install -y python-software-properties nfs-kernel-server
# compiling tools
sudo apt-get install -y make build-essential autoconf gcc g++
# virtualization components
sudo apt-get install -y qemu qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils libcap2-bin virtinst gnome-keyring
}

function enable_kvm_bridged_networking ()
{
if [ $server_arch = "i386" ]; then
    sudo setcap cap_net_admin=ei /usr/bin/qemu
elif [ $server_arch = "amd64" ]; then
    sudo setcap cap_net_admin=ei /usr/bin/qemu-system-x86_64
fi
}

function add_current_user_to_libvirtd ()
{
sudo usermod -a -G libvirtd $USER
}

function configure_network_interfaces ()
{
network_interface_specs=()
network_interface_specs=("${network_interface_specs[@]}"
"# The loopback network interface"
"auto lo"
"iface lo inet loopback"
""
"# System network interface on $system_eth"
"auto $system_eth"
"iface $system_eth inet static"
"       address $set_subnet.$system_ip"
"       network $set_subnet.0"
"       netmask $set_netmask"
"       broadcast $set_subnet.255"
"       gateway $set_subnet.$gateway_ip"
"       dns-nameservers=$nameserver_ip"
""
"# Bridged interface on $bridge_eth"
"auto br0"
"iface br0 inet static"
"       address $set_subnet.$bridged_ip"
"       network $set_subnet.0"
"       netmask 255.255.255.0"
"       broadcast $set_subnet.255"
"       gateway $set_subnet.1"
"       bridge_ports $bridged_eth"
"       bridge_stp off"
"       bridge_fd 0"
"       bridge_maxwait 0"
)

sudo service networking stop
if [ ! -f /etc/network/interfaces.orig ]; then
sudo mv /etc/network/interfaces /etc/network/interfaces.orig
else; sudo rm /etc/network/interfaces
fi 
sudo touch /etc/network/interfaces
for (( i=0;i<${#network_interface_specs[@]};i++)); do
    echo "${network_interface_specs[$i]}"  | sudo tee -a /etc/network/interfaces
done
sudo service networking restart
}

install_packages
configure_network_interfaces
enable_kvm_bridged_networking
add_current_user_to_libvirtd