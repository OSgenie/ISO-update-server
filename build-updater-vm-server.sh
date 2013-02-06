#!/usr/bin/env bash
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function build_updater_environment ()
{
$scriptdir/install-KVM.sh
$scriptdir/buildvm-updater.sh
$scriptdir/install-run-updater-to-crontab.sh
}

check_for_sudo
build_updater_environment