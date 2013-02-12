OSgenie ISO update server
=========================

Scripts for building a host and virtual machines for automatically updating and modifying LiveCD isos to be use in a PXE boot environment

## Designed to be used in conjunction with the OSgenie ISO PXE server
https://github.com/OSgenie/ISO-PXE-server

## Variables are all contained in .config files for easy modification
  1. Currently configured with a 192.168.11.0 subnet 
  2. All variables VM host are in build.config
  3. All variables for the updater VMs are in updater.config 
  
## To build the server follow these steps
  1. Hardware Requirements
    1. RAM - 6144MB min, developed on a system with 8192MB
    2. 64bit CPU with virtualization capability - 2 core min.    
    3. Two hard drives
        1. 4GB+ for root
        2. 1TB+ for /var (hardware RAID 10 preferred)
  2. Install Ubuntu 12.10 Server 64bit
  3. Install Git and Run Build Scripts
      1. sudo apt-get install git-core
      2. git clone https://github.com/OSgenie/ISO-update-server.git
      3. cd ISO-update-server
      4. sudo ./build-updater-vm-server.sh