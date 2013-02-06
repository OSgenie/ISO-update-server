#!/usr/bin/env bash
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/build.config

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function configure_network_interfaces ()
{
ifdown $primary_eth
ifdown $secondary_eth
mv /etc/network/interfaces /etc/network/interfaces.orig
chmod a-w /etc/network/interfaces.orig
cat > /etc/network/interfaces << EOM
# The loopback network interface
auto lo
iface lo inet loopback

# System network interface on $primary_eth
auto $primary_eth
iface $primary_eth inet static
       address $primary_eth_ip
       network $primary_eth_subnet
       netmask $primary_eth_netmask
       broadcast $primary_eth_broadcast
       gateway $primary_eth_gateway
       dns-nameservers $nameserver_1 $nameserver_2

# Bridged interface on $bridge_eth
auto $bridged_int
iface $bridged_int inet static
       address $secondary_eth_ip
       network $secondary_eth_subnet
       netmask $secondary_eth_netmask
       broadcast $secondary_eth_broadcast
       gateway $secondary_eth_gateway
       bridge_ports $secondary_eth
       bridge_stp off
       bridge_fd 0
       bridge_maxwait 0

EOM
ifup $primary_eth
ifup $secondary_eth 
}

function install_packages ()
{
# update system
apt-get update 
apt-get dist-upgrade -y
apt-get install -y python-software-properties software-properties-common nfs-kernel-server
# compiling tools
apt-get install -y make build-essential autoconf gcc g++
# virtualization components
apt-get install -y qemu qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils libcap2-bin virtinst gnome-keyring
}

function enable_kvm_bridged_networking ()
{
if [ $server_arch = "i386" ]; then
    setcap cap_net_admin=ei /usr/bin/qemu
elif [ $server_arch = "amd64" ]; then
    setcap cap_net_admin=ei /usr/bin/qemu-system-x86_64
fi
}

function add_current_user_to_libvirtd ()
{
usermod -a -G libvirtd $USER
}

check_for_sudo
configure_network_interfaces
install_packages
enable_kvm_bridged_networking
add_current_user_to_libvirtd