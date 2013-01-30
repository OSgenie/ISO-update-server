#!/bin/bash
imagedir=$1

function set_servers ()
{
apt_cacher_server=192.168.11.3
nfs_server=192.168.11.3
wget_proxy=192.168.11.3:3128
}

function configure_wget_proxy ()
{
sudo cp $imagedir/etc/wgetrc $imagedir/etc/wgetrc.orig
sudo chmod a-w $imagedir/etc/wgetrc.orig
sudo sed -i "s/#http_proxy = http:\/\/proxy.yoyodyne.com:18023\//http_proxy = http:\/\/$wget_proxy\//g" $imagedir/etc/wgetrc
sudo sed -i "s/#ftp_proxy = http:\/\/proxy.yoyodyne.com:18023\//ftp_proxy = http:\/\/$wget_proxy\//g"  $imagedir/etc/wgetrc
sudo sed -i "s/#use_proxy = on/use_proxy = on/g" $imagedir/etc/wgetrc
}
configure_wget_proxy
function dist-upgrade ()
{
echo 'Acquire::http { Proxy "http://'$apt_cacher_server':3142"; };' | tee $imagedir/etc/apt/apt.conf
chroot $imagedir apt-get update
chroot $imagedir apt-get dist-upgrade -y
chroot $imagedir apt-get autoremove -y
}

function install_packages ()
{
# install install Ubuntu Customization Kit and dependencies
chroot $imagedir apt-get install -y python-software-properties
chroot $imagedir add-apt-repository -y ppa:uck-team/uck-stable && sudo apt-get update
chroot $imagedir apt-get install -y syslinux squashfs-tools genisoimage python-software-properties xauth uck fuse-utils unionfs-fuse nfs-common #sbm
chroot $imagedir apt-get install -yf
}

function create_dirs ()
{
mkdir -p $imagedir/work/live/
mkdir -p $imagedir/work/install/
mkdir -p $imagedir/mnt/OSgenie/
mkdir -p $imagedir/var/nfs/images/
mkdir -p $imagedir/iso/downloads/
mkdir -p $imagedir/iso/nfs/
}

function update_fstab ()
{
echo "# nfs share for updated isos" | tee -a $imagedir/etc/fstab
echo "$nfs_server:/updatediso	/iso/nfs	nfs4	_netdev,auto	0	0" | tee -a $imagedir/etc/fstab
echo "$nfs_server:/transmission/complete	/iso/downloads	nfs4	_netdev,auto	0	0" | tee -a $imagedir/etc/fstab
}

set_servers
configure_wget_proxy
dist-upgrade
install_packages
create_dirs
update_fstab