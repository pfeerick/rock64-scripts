#!/bin/bash
MEM_TEST_MASK=6144
MEM_TEST_SIZE=3GB
MEM_TEST_LOOPS=2

Main() {
	ParseOptions "$@"

	RequireRoot
	CheckDependencies

	LogFile="$(mktemp /tmp/${0##*/}.XXXXXX)"
	MemtesterLogFile="$(mktemp /tmp/${0##*/}.XXXXXX)"

	echo -e "### kernel: \n$(uname -a)" >> ${LogFile}

	echo -e "\n### linux-rock64-package version: \n$(apt-cache policy linux-rock64-package | grep "Installed")" >> ${LogFile}

	trap finishAnyway 1 2 3 6
	echo -e "\n### memtester (mask: ${MEM_TEST_MASK}, size: ${MEM_TEST_SIZE}, loops: ${MEM_TEST_LOOPS}):\n" > ${MemtesterLogFile}
	export MEMTESTER_TEST_MASK=${MEM_TEST_MASK}
	time -f"Runtime: %U user, %S system, %E elapsed" memtester ${MEM_TEST_SIZE} ${MEM_TEST_LOOPS} 2>&1 | tee -a ${MemtesterLogFile}
	echo -e "\nmemtester took $[$(date +%s)-$m] seconds.\n" | tee -a ${MemtesterLogFile}

	echo -e "\n### dmesg:\n$(dmesg)" >> ${LogFile}

	col -b < ${MemtesterLogFile} >>  ${LogFile}

	uploadDebugInfo "${LogFile}"

	exit 0
} # Main

ParseOptions() {
	while getopts 'U:' c ; do
	case ${c} in
		U)
			uploadDebugInfo "${OPTARG}"
			exit 0
			;;
	esac
	done

} # ParseOptions

uploadDebugInfo() {
	fping ix.io 2>/dev/null | grep -q alive || \
	(echo -e "\nNetwork/firewall problem detected. Not able to upload debug info.\nPlease fix this or upload $1 manually\n" >&2 ; exit 1)
	echo -e "Debug information will now be uploaded to \c"
	# we obfuscate IPv4 addresses somehow but not too much, MAC addresses have to remain
	# in clear since otherwise the log becomes worthless due to randomly generated
	# addresses here and there that might conflict

	cat "$1" \
		| sed -E 's/([0-9]{1,3}\.)([0-9]{1,3}\.)([0-9]{1,3}\.)([0-9]{1,3})/XXX.XXX.\3\4/g' \
		| curl -F 'f:1=<-' ix.io
	echo -e "Please post the URL in the forum where you've been asked for it.\n"
} #uploadDebugInfo

finishAnyway() {
	echo -e "\nUser Ctrl+C detected, memtester output will be truncated...\n" | tee -a ${MemtesterLogFile}

	echo -e "\n### dmesg:\n$(dmesg)" >> ${LogFile}
	
	head -40 "${MemtesterLogFile}" >> "${LogFile}"

	uploadDebugInfo "${LogFile}"

	exit 0
} #finishAnyway

RequireRoot() {
	if [ "$(id -u)" != "0" ]; then
		echo "This script requires root privleges - run as root or through sudo. Exiting" >&2
		exit 1
	fi
} # RequireRoot

CheckDependencies() {
	MissingTools=""

	which memtester >/dev/null 2>&1 || MissingTools="${MissingTools} memtester"
	which curl      >/dev/null 2>&1 || MissingTools="${MissingTools} curl"
	which fping     >/dev/null 2>&1 || MissingTools="${MissingTools} fping"
	which col       >/dev/null 2>&1 || MissingTools="${MissingTools} bsdmainutils"

	if [ "X${MissingTools}" != "X" ]; then
		echo -e "Some tools are missing, installing: ${MissingTools}" >&2
		apt-get -f -qq -y install ${MissingTools} >/dev/null 2>&1
	fi
} # CheckDependencies

Main "$@"
