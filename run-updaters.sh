#!/bin/bash
# set crontab to run weekly
available_updaters=$(virsh list --all --name | grep updater)
already_updated=()
next_updaters=()
active_updater=$(virsh list --name | grep updater)
if [ $active_updater == "" ]; then 
    virsh start ${available_updaters[0]}
fi
for (( i=0;i<${#available_updaters[@]};i++)); do
    active_updater=$(virsh list --name | grep updater)
    while [ active_updater != "" ]; do
        sleep 300
        active_updater=$(virsh list --name | grep updater)
    done
        virsh start ${available_updaters[$i]}
        unset ${available_updaters[$i]}
done
