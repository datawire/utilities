do_installation () {
    source="${1}"
    target="${2}"
    support_existing="${3}"

    create_venv=YES

    if [ -n "${support_existing}" ]; then
        if [ \( "${target}" = "venv" \) -o \( "${target}" = "system" \) ]; then
            create_venv=""
        fi
    fi

    if [ -n "${create_venv}" ]; then
        step "Creating installation directory..."

        if [ ! -d "${install_destination}" ]; then
            mkdir -p "${install_destination}"
        fi

        virtualenv -q --python python2.7 "${install_destination}/venv"

        . ${install_destination}/venv/bin/activate
    elif [ "${target}" = "venv" ]; then
        if [ -z "${VIRTUAL_ENV}" ]; then
            echo "Target 'venv' only makes sense in a virtualenv" >&2
            exit 1
        fi

        # RE-activate the existing venv. I'm not sure why my setup clobbers
        # the venv's PATH setting, but it does...
        . ${VIRTUAL_ENV}/bin/activate
    elif [ "${target}" != "system" ]; then
        echo "Impossible: create_venv false but target is ${target}" >&2
        exit 1
    fi

    step "Installing..."

    run_script pkgconf.sh "${source}" "${target}" "preinstall"

    if has_script pkginstall.sh "${source}"; then
        run_script pkginstall.sh "${source}" "${target}" install
    else
        pip --quiet install ${workdir}
    fi

    run_script pkgconf.sh "${source}" "${target}" "postinstall"

    if [ -n "${create_venv}" ]; then
        deactivate
    fi

    step "Installed!"
}
