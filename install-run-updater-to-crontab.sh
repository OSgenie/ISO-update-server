#!/usr/bin/env bash
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function install_scripts_local_bin ()
{
install $scriptdir/run-updaters.sh /usr/local/bin/run-updaters
}

function configure_crontab ()
{
echo "# m h  dom mon dow   command" | crontab -
crontab -l | { cat; echo "0 12 * * wed /usr/local/bin/run-updaters  > /var/log/run-updaters.log"; } | crontab -
}

check_for_sudo
install_scripts_local_bin
configure_crontab