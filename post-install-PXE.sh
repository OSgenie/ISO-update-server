#!/bin/bash
apt_cacher_server=192.168.11.3
tftpboot_root="/var/lib/tftpboot"
imagedir=$1

function install_packages ()
{
echo 'Acquire::http { Proxy "http://'$apt_cacher_server':3142"; };' | tee $imagedir/etc/apt/apt.conf
chroot $imagedir apt-get update
chroot $imagedir apt-get dist-install -y
chroot $imagedir apt-get install -y tftpd-hpa syslinux nfs-kernel-server initramfs-tools
}

function create_directories ()
{
mkdir -p $imagedir/mnt/pxeboot
echo "create kernel directories"
mkdir -p $imagedir/$tftpboot_root/boot/
echo "create PXE menu directories"
mkdir -p $imagedir/$tftpboot_root/menus/stock
mkdir -p $imagedir/$tftpboot_root/menus/live
mkdir -p $imagedir/$tftpboot_root/menus/install
}

function configure_tftpd ()
{
echo 'RUN_DAEMON="yes"' | tee -a $imagedir/etc/default/tftpd-hpa
echo 'OPTIONS="-l -s $tftpboot_root"' | tee -a $imagedir/etc/default/tftpd-hpa
/etc/init.d/tftpd-hpa restart
}

function copy_pxelinux ()
{
cd $imagedir/$tftpboot_root
wget http://us.archive.ubuntu.com/ubuntu/dists/precise/main/installer-i386/current/images/netboot/ubuntu-installer/i386/boot-screens/vesamenu.c32
wget http://us.archive.ubuntu.com/ubuntu/dists/precise/main/installer-i386/current/images/netboot/ubuntu-installer/i386/pxelinux.0
}

function set_pxelinux_default ()
{
mkdir $imagedir/$tftpboot_root/pxelinux.cfg
touch $imagedir/$tftpboot_root/pxelinux.cfg/default
echo "# D-I config version 2.0" | tee $imagedir/$tftpboot_root/pxelinux.cfg/default
echo "include mainmenu.conf" | tee -a $imagedir/$tftpboot_root/pxelinux.cfg/default
echo "default vesamenu.c32" | tee -a $imagedir/$tftpboot_root/pxelinux.cfg/default
echo "TIMEOUT 600" | tee -a $imagedir/$tftpboot_root/pxelinux.cfg/default
echo "ONTIMEOUT localboot" | tee -a $imagedir/$tftpboot_root/pxelinux.cfg/default
echo "prompt 0" | tee -a $imagedir/$tftpboot_root/pxelinux.cfg/default
echo "timeout 0" | tee -a $imagedir/$tftpboot_root/pxelinux.cfg/default
}

install_packages
create_directories
configure_tftpd
copy_pxelinux
set_pxelinux_default