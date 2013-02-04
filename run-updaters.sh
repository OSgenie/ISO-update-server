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
            echo "+-------------------------------------------------------------------+"    
            echo "+ RUNNING ${available_updaters[$updater]}"
            echo "+ `date +%c`"
            echo "+-------------------------------------------------------------------+"    
            virsh start ${available_updaters[$updater]}
            updater=$((updater+1))
        fi
    fi
    sleep 300
done
}

check_for_sudo
run_updaters