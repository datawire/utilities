#!/usr/bin/env bash

set -e
set -o pipefail

source="$1"; shift
dest="$1"; shift
phase="$1"; shift

if [ $VERBOSITY -gt 2 ]; then
	echo "${green}Running ${phase} hook${normal}"

	if [ $VERBOSITY -gt 3 ]; then
		echo "Source ${source}"
		echo "Dest   ${dest}"
	fi
fi

if [ "$phase" == "postinstall" ]; then
	rm -f "${dest}/Makefile"
	rm -f "${dest}/install.sh"
	rm -f "${dest}/pkgconf.sh"
fi

