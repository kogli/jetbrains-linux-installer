#!/bin/bash
dest="/usr/local/bin"
destFile="$dest/jetbrains-get"
source="./jetbrains-get.sh"

if [ $(id -u) -ne 0 ]; then
	SUDO='sudo'
fi
$($SUDO mkdir -p $dest)
$($SUDO cp $source $destFile)
$($SUDO chmod +x $destFile)
$($SUDO chown root:root $destFile)

echo "jetbrains-get installed"
