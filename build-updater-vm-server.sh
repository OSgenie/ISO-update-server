#!/usr/bin/env bash
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$scriptdir/install-KVM.sh
$scriptdir/buildvm-updater.sh
$scriptdir/install-run-updater-to-crontab.sh