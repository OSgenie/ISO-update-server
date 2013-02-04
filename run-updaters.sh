#!/bin/bash
# set crontab to run weekly
available_updaters=()
available_updaters=(${available_updaters[@]} $(virsh list --all --name | grep updater))
updater=0

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function run_updaters ()
{
echo "+-------------------------------------------------------------------+"
echo "+ Starting Weekly Update with" 
echo "+ ${available_updaters[@]}"
echo $updater
echo "+-------------------------------------------------------------------+"
for i in {1..2000}; do
    active_updater=$(virsh list --name | grep updater)
    echo "Active updater - $active_updater"
    if [ "$active_updater" == "" ]; then
        if [ $updater == ${#available_updaters[@]} ]; then
            echo "+-------------------------------------------------------------------+"
            echo "All Update Servers have run"
            echo "+-------------------------------------------------------------------+"
            exit
        else
            echo $updater            
            echo "+-------------------------------------------------------------------+"    
            echo "+ RUNNING ${available_updaters[$server]}"
            echo "+ `date +%c`"
            echo "+-------------------------------------------------------------------+"    
            virsh start ${available_updaters[$server]}
            updater=$((updater+1))
            echo $updater
        fi
    fi
    sleep 30
done
}

check_for_sudo
run_updaters