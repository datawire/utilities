#### Module to handle argument parsing

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
	    install_from_url "https://github.com/datawire/{{{PACKAGE_NAME}}}/archive/${branch}.zip"
    else
        install_from_url "${default_source}"
    fi
fi

if [ -z "$install_destination" ]; then
    install_destination="${default_destination}"
fi

msg "Installing from ${worksource}"
msg "Installing to   ${install_destination}"
