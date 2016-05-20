#!/usr/bin/env sh

{ # this ensures the entire script is downloaded #

set -e

{{{MODULES}}}

step "Performing installation environment sanity checks..."
required_commands curl egrep unzip python virtualenv
is_already_installed

is_importable "{{{PACKAGE_NAME}}}"

if [ -n "{{{PACKAGE_CHECK_EXEC}}}" ]; then
    is_on_path "{{{PACKAGE_CHECK_EXEC}}}"
fi

download
do_installation "${workdir}" "${install_destination}"

} # this ensures the entire script is downloaded #
