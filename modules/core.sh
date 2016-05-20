#### CORE MODULES -- include this first.

# Defaults
default_source="{{{DEFAULT_SOURCE}}}"
default_destination="{{{DEFAULT_DESTINATION}}}"

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

# We can install from a URL or from a directory. The install_from_... 
# functions set up the 'download' function to do the right thing.

install_from_url () {   # OUTPUT IN $workdir, $worksource
    URL="$1"

    install_source="${URL}"
    worksource="URL ${URL}"     # OUTPUT

    download() {
        step "Downloading..."
        work=$(mktemp -d ${TMPDIR:-/tmp}/datawire-installer-{{{PACKAGE_NAME}}}.XXXXXXXX)

        zipfile="${work}/install.zip"
        workdir="${work}/installdir"    # OUTPUT

        CURLVERBOSITY="-#"

        if [ $VERBOSITY -lt 1 ]; then
            CURLVERBOSITY="-s -S"
        elif [ $VERBOSITY -gt 2 ]; then
            CURLVERBOSITY=
        fi

        curl ${CURLVERBOSITY} ${CURLEXTRAARGS} -L "${URL}" > "${zipfile}"

        if [ $VERBOSITY -gt 5 ]; then
            echo "Downloaded:"
            unzip -t "${zipfile}"
        fi

        if unzip -q -d "${workdir}" "${zipfile}" >> "${work}/install.log" 2>&1; then
            step "Download succeeded"

            total_count=$(cd "${workdir}" ; ls -1 | wc -l)
            pkg_count=$(cd "${workdir}" ; ls -1 | egrep "^{{{PACKAGE_NAME}}}-" | wc -l)

            if [ \( $total_count -eq 1 \) -a \( $pkg_count -eq 1 \) ]; then
                # Silly GitHub is silly.
                one_dir_up=$(dirname "${workdir}")/"{{{PACKAGE_NAME}}}"
                mv "${workdir}/{{{PACKAGE_NAME}}}"-* "${one_dir_up}"
                rm -rf "${workdir}"
                mv "${one_dir_up}" "${workdir}"
            fi

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
    script="$1"; shift
    source="$1"; shift

    test -f "${source}/${script}"
}

run_script () {
    script="$1"; shift
    source="$1"; shift
    target="$1"; shift
    phase="$1"; shift

    if has_script "${script}" "${source}"; then
        bash "${source}/${script}" "${source}" "${target}" "${phase}"
    else
        true
    fi
}

