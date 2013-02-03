#!/bin/bash
# set crontab to run weekly
available_updaters=()
available_updaters=(${available_updaters[@]} $(virsh list --all --name | grep updater))
server=0

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function run_updaters ()
{
echo "Available updaters - ${available_updaters[@]}"
for i in {1..2000}; do
echo "Active updater - $active_updater"
    active_updater=$(virsh list --name | grep updater)
    if [ active_updater != "" ]; then
        echo ${available_updaters[$server]}
        virsh start ${available_updaters[$server]}
        server=$((server++))
    fi
    if [ $server == ${#available_updaters[@]} ]; then
        echo "All Updaters have run"
        exit
    fi
    sleep 300
done
}

check_for_sudo
run_updaters