#!/bin/bash
# set crontab to run weekly
available_updaters=$(virsh list --all --name | grep updater)
already_updated=()
next_updaters=()
active_updater=$(virsh list --name | grep updater)
server=0

echo "Available updaters - ${available_updaters[@]}"
echo "Active updater - $active_updater"
for i in {1..2000}; do
    active_updater=$(virsh list --name | grep updater)
    if [ active_updater != "" ]; do
        echo "${available_updaters[$server]}"
        virsh start ${available_updaters[$server]}
        server=$((server++))
    fi
    if [ $server > ${#available_updaters[@]}]; then
        echo "All Updaters have run"
        exit
    fi
    sleep 300
done
