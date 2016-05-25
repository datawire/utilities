do_installation () {
    source="${1}"
    target="${2}"
    support_existing_venv="${3}"

    if [ -n "${support_existing_venv}" -a \( "${target}" = "venv" \) ]; then
        if [ -z "${VIRTUAL_ENV}" ]; then
            echo "Target 'venv' only makes sense in a virtualenv" >&2
            exit 1
        fi

        # RE-activate the existing venv. I'm not sure why my setup clobbers
        # the venv's PATH setting, but it does...
        . ${VIRTUAL_ENV}/bin/activate
    else
        step "Creating installation directory..."

        if [ ! -d "${install_destination}" ]; then
            mkdir -p "${install_destination}"
        fi

        virtualenv -q --python python2.7 "${install_destination}/venv"

        . ${install_destination}/venv/bin/activate
    fi

    step "Installing..."

    run_script pkgconf.sh "${source}" "${target}" "preinstall"

    if has_script pkginstall.sh "${source}"; then
        run_script pkginstall.sh "${source}" "${target}" install
    else
        pip --quiet install ${workdir}
    fi

    run_script pkgconf.sh "${source}" "${target}" "postinstall"

    if [ -z "${support_existing_venv}" -o \( "${target}" != "venv" \) ]; then
        deactivate
    fi

    step "Installed!"
}
