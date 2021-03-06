#!/usr/bin/env sh

{ # this ensures the entire script is downloaded #

set -e

{{{MODULES}}}

step "Performing installation environment sanity checks..."
required_commands curl egrep unzip
is_already_installed

download
do_installation "${workdir}" "${install_destination}"

} # this ensures the entire script is downloaded #
