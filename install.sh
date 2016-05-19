#!/usr/bin/env sh

{ # this ensures the entire script is downloaded #

set -e

# Defaults
default_source="https://github.com/datawire/utilities/archive/master.zip"
default_destination="utilities"

install_source=
install_destination=

# Get the script directory
SCRIPT_SOURCE="${0}"
while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SCRIPT_SOURCE until the file is no longer a symlink
  SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"
  SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
  [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE" # if $SCRIPT_SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"

# Check if stdout is a terminal...
if [ -t 1 ]; then

    # See if it supports colors...
    ncolors=$(tput colors)

    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

# Assume pretty verbose output
VERBOSITY=3

# Define a bunch of pretty output helpers
output () {
    lvl="$1"
    fmt="$2"
    text="$3"

    if [ $VERBOSITY -ge $lvl ]; then
        printf -- "$fmt" "$text"
    fi
}

msg () {
    output 1 "%s\n" "$1"
}

step () {
    output 2 "--> %s\n" "$1"
}

substep () {
    output 3 "-->  %s\n" "$1"
}

die() {
    printf "${red}FAIL${normal}"
    printf "\n\n        "
    printf "$1"
    printf "\n\n"
    exit 1
}

# We can install from a URL or from a directory. The install_from_... 
# functions set up the 'download' function to do the right thing.

install_from_url () {   # OUTPUT IN $workdir, $worksource
    URL="$1"

    install_source="${URL}"
    worksource="URL ${URL}"     # OUTPUT

    download() {
        step "Downloading..."
        work=$(mktemp -d ${TMPDIR:-/tmp}/datawire-installer-utilities.XXXXXXXX)

        zipfile="${work}/install.zip"
        workdir="${work}/installdir"    # OUTPUT

        CURLVERBOSITY="-#"

        if [ $VERBOSITY -lt 1 ]; then
            CURLVERBOSITY="-s -S"
        elif [ $VERBOSITY -gt 2 ]; then
            CURLVERBOSITY=
        fi

        curl $CURLVERBOSITY -L ${URL} > "${zipfile}"

        if [ $VERBOSITY -gt 5 ]; then
            echo "Downloaded:"
            unzip -t "${zipfile}"
        fi

        if unzip -q -j -d "${workdir}" "${zipfile}" >> "${work}/install.log" 2>&1; then
            step "Download succeeded"
        else
            die "Unable to download from ${URL}\n        check in ${work}/install.log for details."
        fi
    }
}

install_from_dir () {   # OUTPUT IN $workdir, $worksource
    workdir="$1"        # OUTPUT
    worksource="directory ${workdir}"     # OUTPUT

    install_source="${workdir}"

    download () {
        # Nothing to do here. Cool.
        :
    }
}

has_script () {
    source="$1"

    test -f "${source}/pkgconf.sh"
}

run_script () {
    source="$1"
    target="$2"
    phase="$3"

    if has_script "${source}"; then
        bash "${source}/pkgconf.sh" "${source}" "${target}" "${phase}"
    else
        true
    fi
}

# Actually do the installation of the downloaded files
do_installation () {
    source="${1}"
    target="${2}"

    run_script "${source}" "${target}" "preinstall"
    step "Installing..."

    if has_script "${source}"; then
        run_script "${source}" "${target}" install
    else
        cp -pr "${source}" "${target}"
    fi

    run_script "${source}" "${target}" "postinstall"

    step 'Finished!'
}

while getopts ':d:f:t:qv' opt; do
    case $opt in
        d)  install_from_dir "$OPTARG"
            ;;

        f)  install_from_url "$OPTARG"
            ;;

        t)  install_destination="$OPTARG"
            ;;

        :)  echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;

        q)  VERBOSITY=$(( $VERBOSITY - 1 ))
            if [ $VERBOSITY -lt 0 ]; then VERBOSITY=0; fi
            ;;

        v)  VERBOSITY=$(( $VERBOSITY + 1 ))
            ;;

        \?) echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "$install_source" ]; then
    if [ -n "$1" ]; then
	    branch="$1"
	    install_from_url "https://github.com/datawire/utilities/archive/${branch}.zip"
    else
        install_from_url "${default_source}"
    fi
fi

if [ -z "$install_destination" ]; then
    install_destination="${default_destination}"
fi

msg "Installing from ${worksource}"
msg "Installing to   ${install_destination}"

download
do_installation "${workdir}" "${install_destination}"

} # this ensures the entire script is downloaded #
