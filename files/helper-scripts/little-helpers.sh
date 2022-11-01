# This should be used only by individual toolchain pieces
#

function FixupLibdir() {
    # Arg 1: Path to toolchain root, e.g. %{install-root}%{path_target_toolchain} or sysroot
    [ -z "${1}" ] && exit 11
    if [ -d ${1}/lib64 -a \! -L ${1}/lib64 ]; then
        mkdir -p ${1}/lib
        mv ${1}/lib64/* ${1}/lib/
        rm -rf ${1}/lib64
        ln -sfv lib ${1}/lib64
    fi
    if [ -d ${1}/lib32 -a \! -L ${1}/lib32 ]; then
        echo "Error: Why does 'lib32' exist and it's not a symlink?"
        exit 12
    elif [ ! -e ${1}/lib32 ]; then
        ln -sfv lib ${1}/lib32
    fi
}

function FixupUsrdir() {
    # Arg 1: Path to toolchain root, e.g. %{install-root}%{path_target_toolchain} or sysroot
    [ -z "${1}" ] && exit 11
    if [ -d ${1}/usr -a \! -L ${1}/usr ]; then
        mv ${1}/usr/* ${1}/
        rm -rf ${1}/usr
        ln -sfv . ${1}/usr
    elif [ ! -e ${1}/usr ]; then
        ln -sfv . ${1}/usr
    fi
}

function TripletSymlinks() {
    # Arg 1: Path to toolchain root, e.g. %{install-root}%{path_target_toolchain}
    # Arg 2: Original Triplet used, e.g. arm-rbst-linux-gnueabi
    # Arg 3: Other Triplet used, e.g. arm-linux-gnueabi
    [ -z "${1}" ] && exit 11
    [ -z "${2}" ] && exit 12
    [ -z "${3}" ] && exit 13
    set -eu
    [ ! -d ${1}/bin ] && echo "Error: Arg 1 '${1}' not a directory" && exit 21
    cd ${1}/bin
    for app in ${2}-*; do
        ln -sfv $app ${3}${app#${2}}
    done
}