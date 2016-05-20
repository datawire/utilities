#### Module to install shell files
do_installation () {
    source="${1}"
    target="${2}"

    step "Installing..."

    run_script pkgconf.sh "${source}" "${target}" "preinstall"

    if has_script pkginstall.sh "${source}"; then
        run_script pkginstall.sh "${source}" "${target}" install
    else
        cp -pr "${source}" "${target}"
    fi

    run_script pkgconf.sh "${source}" "${target}" "postinstall"

    step 'Finished!'
}
