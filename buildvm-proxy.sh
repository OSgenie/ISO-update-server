#!/bin/bash
# Script for creating KVM virtual machines
# Kirtley Wienbroer
# kirtley@osgenie.com
# January 26 2013
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec_script=
newhost=pxeserver
RAMsize=384
vmflavour=virtual
vmarch=i386
release=precise
apt_cache="http://192.168.11.10:3142/ubuntu"
subnet=192.168.122
subnet_mask=255.255.255.0
ip=2

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function set_username ()
{
read -p "User Name: " username
read -p "Full Name: " fullname
}

function set_password ()
{
read -s -p "Set Password: " userpassword
echo ""
read -s -p "Confirm Password: " confirmpassword
echo ""
}

function verify_password ()
{
if [ $userpassword == $confirmpassword ]; then
    echo "Thank you"
else
    echo "Passwords didn't match, please reenter."
    set_password
fi
}
 
function define_partition_specs ()
{
partition_specs=(
"root 6000"
"swap 4000"
)
rm vmbuilder.partition
touch vmbuilder.partition
for (( i=0;i<${#partition_specs[@]};i++)); do
    echo "${partition_specs[$i]}"  | tee -a vmbuilder.partition
done
}

function build_vm ()
{
echo "Building vm $newhost ..."
vmbuilder kvm ubuntu \
    --exec=$current_dir/$exec_script \
    --suite=$release \
    --flavour=$vmflavour \
    --arch=$vmarch \
    --mem=$RAMsize \
    --part=vmbuilder.partition \
    --libvirt=qemu:///system \
    --hostname=$newhost \
    --ip=$subnet"."$ip \
    --mask=$subnet_mask \
    --bcast=$subnet".255" \
    --dns=$subnet".1"  \
    --gw=$subnet".1" \
    --bridge=br0 \
    --user=$username \
    --name=$fullname \
    --pass=$userpassword \
    --addpkg=acpid \
    --addpkg=p11-kit \
    --addpkg=unattended-upgrades \
    --addpkg=openssh-server \
    --addpkg=git-core \
    --addpkg=iptables \
    --addpkg=update-motd \
    --addpkg=landscape-common \
    --destdir=/var/lib/libvirt/images/$newhost
virsh autostart $newhost
}

check_for_sudo
set_username
set_password
verify_password
define_partition_specs
build_vm
virsh start $newhost
virsh list --all

#    --mirror=$apt_cache \
#    --security-mirror=$apt_cache \