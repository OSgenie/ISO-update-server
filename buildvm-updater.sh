#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec_script=post-install-UCK.sh
RAMsize=5120
vmflavour=server
apt_cache="http://192.168.11.3:3142/ubuntu"
subnet=192.168.11
subnet_mask=255.255.255.0

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
"---"
"/work 200000"
)
rm vmbuilder.partition
touch vmbuilder.partition
for (( i=0;i<${#partition_specs[@]};i++)); do
    echo "${partition_specs[$i]}"  | tee -a vmbuilder.partition
done
}

function build_vm ()
{
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ BUILDING -- $newhost @ $subnet.$ip"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
vmbuilder kvm ubuntu \
    --exec=$current_dir/$exec_script \
    --suite=$release \
    --flavour=$vmflavour \
    --arch=$vmarch \
    --mem=$RAMsize \
    --cpus=2 \
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
    --addpkg=linux-image-generic \
    --destdir=/var/lib/libvirt/images/$newhost
}

check_for_sudo
set_username
set_password
verify_password
define_partition_specs

cpu_arch="i386 amd64"
releases="precise quantal"
ip=20 #starting IP address
for vmarch in $cpu_arch; do
    for release in $releases; do
        newhost=updater-$release-$vmarch
        if [ ! -d /var/lib/libvirt/images/$newhost ]; then
        build_vm
        fi
        ip=$((ip+1))
    done
done
virsh list --all
#    --mirror=$apt_cache \
#    --security-mirror=$apt_cache \