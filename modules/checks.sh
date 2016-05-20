#### Machinery for checking for certain required stuff.

required_commands () {
    for cmd in $*; do
        substep "Checking for ${cmd}: "
        loc=$(command -v ${cmd} || true)
        if [ -n "${loc}" ]; then
            substep_ok
        else
            die "Cannot find ${cmd}, please install and try again."
        fi
    done
}

is_on_path () {
    cmd="$1"; shift

    substep "Checking for '${cmd}' on \$PATH: "
    if command -v "${cmd}" >/dev/null 2>&1 ; then
        die "Found '${cmd}' already on \$PATH, please (re)move to proceed."
    else
        substep_ok
    fi
}

is_importable () {
    module="$1"; shift

    substep "Checking for '${module}' Python module pollution: "
    set +e
    python -c "import ${module}" >/dev/null 2>&1
    result=$?
    set -e
    if [ "${result}" -eq 0 ]; then
        die "Python module '${module}' already present, please remove to proceed."
    else
        substep_ok
    fi
}

is_already_installed () {
    substep "Checking for old {{{PACKAGE_NAME}}}: "
    if [ -e ${install_destination} ]; then
        die "Install directory exists at '${install_destination}', please (re)move to proceed."
    else
        substep_ok
    fi
}
