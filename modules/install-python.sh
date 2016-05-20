#### Module to install Python files
do_installation () {
    source="${1}"
    target="${2}"

    step "Creating installation directory..."

    if [ ! -d "${install_destination}" ]; then
        mkdir -p "${install_destination}"
    fi

    virtualenv -q --python python2.7 "${install_destination}/venv"

    . ${install_destination}/venv/bin/activate

    step "Installing..."

    run_script pkgconf.sh "${source}" "${target}" "preinstall"

    if has_script pkginstall.sh "${source}"; then
        run_script pkginstall.sh "${source}" "${target}" install
    else
        pip --quiet install ${workdir}
    fi

    run_script pkgconf.sh "${source}" "${target}" "postinstall"

    deactivate

    step "Installed!"
}
