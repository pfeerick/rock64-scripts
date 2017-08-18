#!/bin/bash

Log="/var/log/${0##*/}.log"

Main() {
	RequireRoot

	stty rows 30 cols 132
	clear

	echo "iozone test script"
	echo "Log file location: ${Log}"

	#check prerequisites
	which iozone >/dev/null 2>&1 || MissingTools=" izone"

	if [ "X${MissingTools}" != "X" ]; then
		echo -e "Some tools are missing, installing: ${MissingTools}" >&2
		apt-get -f -qq -y install ${MissingTools} >/dev/null 2>&1
	fi

	scalingGovernorPath="/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
	echo performance > ${scalingGovernorPath}

	deviceMemory=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
	scalingGovernor=$(cat ${scalingGovernorPath})
	kernelVersion=$(uname -r)
	imageVersion=$(apt-cache policy linux-rock64-package | grep Installed | cut -d ":" -f2)

	case $(findmnt / -n -o SOURCE) in
		/dev/mmcblk0p7)
			name=eMMC
			rootPath="/dev/mmcblk0p7"
			;;

		/dev/mmcblk1p7)
			name=SD
			rootPath="/dev/mmcblk1p7"
		   ;;

		*)
			echo "Unknown disk for /"
			exit 1
			;;
	esac

	echo "Root filesystem is located on ${name} (${rootPath})" | tee ${Log}
	echo "Device Memory: ${deviceMemory} kB" | tee -a ${Log}
	echo "CPU scaling governor: ${scalingGovernor}" | tee -a ${Log}
	echo "Kernel version is: ${kernelVersion}" | tee -a ${Log}
	echo "Image version is:${imageVersion}" | tee -a ${Log}
	echo "" | tee -a ${Log}

	echo "Running iozone benchmark... this will take a while!"

	#iozone with realtime screen output
	INITIAL_PATH=$PWD
	echo "Saving PWD, and changing to $(realpath ~) for iozone test ..."
	cd ~
	stdbuf -oL iozone -e -I -a -s 100M -r 4k -r 16k -r 512k -r 1024k -r 16384k -i 0 -i 1 -i 2 | tee -a ${Log}

	echo "Restoring initial PWD..."
	echo ""
	cd $INITIAL_PATH

	#upload results
	echo "Uploading results, link will appear below momentarily..."
	cat ${Log} | curl -F 'sprunge=<-' http://sprunge.us

	exit 0
} # Main

RequireRoot() {
	if [ "$(id -u)" != "0" ]; then
		echo "${0##*/} requires root privleges - run as root or through sudo. Exiting" >&2
		exit 1
	fi
} # RequireRoot

Main "$@"
