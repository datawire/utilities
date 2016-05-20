#### Module with a bunch of output primitives.

# Check if stdout is a terminal...
if [ -t 1 ]; then

    # See if it supports colors...
    ncolors=$(tput colors)

    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        export bold="$(tput bold)"
        export underline="$(tput smul)"
        export standout="$(tput smso)"
        export normal="$(tput sgr0)"
        export black="$(tput setaf 0)"
        export red="$(tput setaf 1)"
        export green="$(tput setaf 2)"
        export yellow="$(tput setaf 3)"
        export blue="$(tput setaf 4)"
        export magenta="$(tput setaf 5)"
        export cyan="$(tput setaf 6)"
        export white="$(tput setaf 7)"
    fi
fi

# Assume pretty verbose output
export VERBOSITY=3

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
    output 3 "-->  %s" "$1"
}

substep_ok() {
    output 3 "${green}OK${normal}\n" ""
}

substep_skip() {
    output 3 "${yellow}OK${normal}\n" "$1"
}

die() {
    printf "${red}FAIL${normal}"
    printf "\n\n        "
    printf "$1"
    printf "\n\n"
    exit 1
}
