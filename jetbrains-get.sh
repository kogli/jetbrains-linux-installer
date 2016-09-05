#!/bin/bash
temp="/tmp/jetbrains-install"
installDest='/opt'

codes=()
names=()

installDir='/opt'
removeDownloads=0
forceDownload=0
noLaunch=0

function askSudo {
	if [ $(id -u) -ne 0 ]; then
		SUDO='sudo'
		sudo echo 'Root access acquired'
	fi
}

function helpcmd {
	echo "Usage:
	jetbrains-get install [packages] [options]	Installs/upgrades packages
	jetbrains-get upgrade [packages] [options]	Installs/upgrades packages
	jetbrains-get remove [packages]			Uninstalls packages
	jetbrains-get clean				Removes all downloaded files
	jetbrains-get --help				Prints this help message and quits

Packages:
	clion, phpstorm, idea, idea-community, datagrip, pycharm, pycharm-community, rubymine

Options:
	--no-launch		Will not launch the program after installation
	--remove-downloads	Will remove all downloaded files after installation
	--force-download	Will force redownload even if file exists on disk"
	exit 1
}

for var in "$@"; do
	#'names' array contains the names of the .sh files
	if [ "$var" = "clion" ]; then
		codes+=('CL')
		names+=('clion')

	elif [ "$var" = "phpstorm" ]; then
		codes+=('PS')
		names+=('phpstorm')

	elif [ "$var" = "idea" ]; then
		codes+=('IIU')
		names+=('idea')

	elif [ "$var" = "idea-community" ]; then
		codes+=('IIC')
		names+=('idea')

	elif [ "$var" = "datagrip" ]; then
		codes+=('DG')
		names+=('datagrip')

	elif [ "$var" = "pycharm" ]; then
		codes+=('PCP')
		names+=('pycharm')

	elif [ "$var" = "pycharm-community" ]; then
		codes+=('PCC')
		names+=('pycharm')

	elif [ "$var" = "rubymine" ]; then
		codes+=('RM')
		names+=('rubymine')

	elif [ "$var" = "webstorm" ]; then
		codes+=('WS')
		names+=('webstorm')

	elif [ "$var" = "--remove-downloads" ]; then
		removeDownloads=1

	elif [ "$var" = "--force-download" ]; then
		forceDownload=1

	elif [ "$var" = "--no-launch" ]; then
		noLaunch=1
	fi
done

function checkPackages {
	if [ ${#codes[@]} -eq 0 ]; then
		echo "No packages specified. See --help for more"
		exit 2
	fi
}

function download {
	dest=$1
	source=$2
	name=$3

	cd $temp
	
	if [ ! -f $dest ] || [ $forceDownload -eq 1 ]; then
		echo "$name:	Removing old downloads..."
		find . -iname "$name*" -exec rm -rf "{}" 2> /dev/null +
		echo "$name:	Downloading $source ..."
		wget -O $dest $source -q --show-progress
	else
		echo "$name:	File $source already downloaded"
	fi

	echo "$name:	Extracting..."
	rm -rf $name 2> /dev/null
	mkdir -p $name
	if ! $(tar -xf $dest --strip=1 -C $name 2> /dev/null); then
		echo "$name:	Extraction failed!"
		echo "$name:	Forcing download..."
		forceDownload=1
		download $dest $source $name
	fi
}

function installcmd {
	checkPackages
	askSudo

	mkdir -p $temp
	cd $temp
	for i in $(seq 1 ${#codes[@]}); do
		code=${codes[$(($i-1))]};
		name=${names[$(($i-1))]};
		echo "$name:	Getting metadata..."
		json="$code.json"
		wget -O "$json" "https://data.services.jetbrains.com/products/releases?code=$code&latest=true&type=release" -q

		prefix='"linux":[{]"link":"'
		regex='.*?[^\\]'
		suffix='",'
		result=$(cat "$json" | grep -Po "$prefix$regex$suffix")
		result=${result#$prefix}
		result=${result%$suffix}

		dfile=$(basename $result)
		download $dfile $result $name

		echo "$name:	Removing leftovers..."
		rm -rf $json 2> /dev/null

		echo "$name:	Installing..."	
		$($SUDO rm -rf $installDest/$name 2> /dev/null)
		$($SUDO mv $name $installDest)
		$($SUDO chmod -R o+rw $installDest/$name)
		$($SUDO chown -R root:root $installDest/$name)
		echo "$name:	Package installed."

		if [ $removeDownloads -eq 0 ]; then
			echo "$name:	Download is preserved at $temp/$dfile"
		fi
	done

	for i in $(seq 1 ${#codes[@]}); do
		name=${names[$(($i-1))]};
		if [ $noLaunch -eq 0 ]; then
			echo "$name:	Launching..."
			echo "$name:	Don't forget to create a desktop entry in 'Configure' -> 'Create Desktop Entry'!"
			logFile=$temp/$name'Install.log'
			rm -rf $logFile 2> /dev/null
			$($installDest/$name/bin/$name.sh > $logFile 2>&1)

			if [ -s $logFile ]; then
				echo "$name:	The launch outputted some errors/warnings! Find them in $logFile"
			fi
		else
			echo "$name:	Launch the program with $installDest/$name/bin/$name.sh";
			echo "$name:	Don't forget to create a desktop entry in 'Configure' -> 'Create Desktop Entry'!"
		fi
	done
}

function removecmd {
	checkPackages
	askSudo

	if [ ! -d $temp ]; then
		echo "No packages installed."
		echo "Done!"
		exit 1
	fi

	cd $installDest
	for i in $(seq 1 ${#codes[@]}); do
		name=${names[$(($i-1))]};
		
		if [ -d "$name" ]; then
			echo "$name:	Removing..."
			$($SUDO rm -rf $name 2> /dev/null)
		else
			echo "$name:	Package is not installed."
		fi
	done

	echo "Done!"
}

if [ "$1" = "install" ] || [ "$1" = "upgrade" ]; then
	installcmd
elif [ "$1" = "remove" ]; then
	removecmd
	exit 1
elif [ "$1" = "clean" ]; then
	removeDownloads=1
elif [ "$1" = "--help" ]; then
	helpcmd
	exit 1
elif [ ${#@} -eq 0 ]; then
	echo "No command specified. See --help for more"
	exit 2
else
	echo "Wrong command specified. See --help for more"
	exit 2
fi

if [ $removeDownloads -eq 1 ]; then
	rm -rf $temp 2> /dev/null #always
	echo "All downloads removed."
else
	rmdir $temp 2> /dev/null #only if empty
fi
