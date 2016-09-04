#!/bin/bash
dest="/usr/local/bin/jetbrains-get"
source="./jetbrains-get.sh"

if [ $(id -u) -ne 0 ]; then
	SUDO='sudo'
fi

$($SUDO cp $source $dest)
$($SUDO chmod +x $dest)
$($SUDO chown root:root $dest)
