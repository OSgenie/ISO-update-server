#!/usr/bin/env bash
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/updater.config
imagedir=$1

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function configure_wget_proxy ()
{
cp $imagedir/etc/wgetrc $imagedir/etc/wgetrc.orig
chmod a-w $imagedir/etc/wgetrc.orig
sed -i "s/#http_proxy = http:\/\/proxy.yoyodyne.com:18023\//http_proxy = http:\/\/$wget_proxy\//g" $imagedir/etc/wgetrc
sed -i "s/#ftp_proxy = http:\/\/proxy.yoyodyne.com:18023\//ftp_proxy = http:\/\/$wget_proxy\//g"  $imagedir/etc/wgetrc
sed -i "s/#use_proxy = on/use_proxy = on/g" $imagedir/etc/wgetrc
}

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
chroot $imagedir apt-get install -y syslinux squashfs-tools genisoimage xauth fuse-utils unionfs-fuse nfs-common #sbm
wget http://superb-dca2.dl.sourceforge.net/project/uck/uck/2.4.6/uck_2.4.6-0ubuntu1_all.deb && mv uck_2.4.6*.deb $imagedir/tmp/
chroot $imagedir dpkg -i /tmp/uck_2.4.6*.deb
chroot $imagedir apt-get install -yf
chroot $imagedir apt-get install -y python-software-properties software-properties-common
chroot $imagedir add-apt-repository -y ppa:uck-team/uck-stable && apt-get update && apt-get install -y uck
chroot $imagedir apt-get install -yf
chroot $imagedir sed -i 's/cp -f \/etc\/resolv.conf \"$REMASTER_DIR\/etc\/resolv.conf\"/cp -d \/etc\/resolv.conf \"$REMASTER_DIR\/etc\/resolv.conf\"/g' /usr/lib/uck/remaster-live-cd.sh
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

configure_wget_proxy
dist-upgrade
install_packages
create_dirs
update_fstab