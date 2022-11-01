#!/usr/bin/env bash
# This script moves the finalized toolchain to respective sysroot and imageprep directories
set -eu

mkdir -p ${INSTROOT}${PATH_STAGING_SYSROOT}/{usr/include,lib,usr/lib}
mkdir -p ${INSTROOT}${PATH_STAGING_IMAGE}/{lib,usr/lib}

# Symlink lib64 to lib, is an unneeded separation for non-multilib platforms:
if [[ "${TARGET_ARCH_IS_64}" == "true" ]]; then
    ln -sf lib ${INSTROOT}${PATH_STAGING_SYSROOT}/lib64
    ln -sf lib ${INSTROOT}${PATH_STAGING_SYSROOT}/usr/lib64
    ln -sf lib ${INSTROOT}${PATH_STAGING_IMAGE}/lib64
    ln -sf lib ${INSTROOT}${PATH_STAGING_IMAGE}/usr/lib64
fi

# touch ${INSTROOT}${PATH_STAGING_SYSROOT}/{usr/include,lib,usr/lib}/.keep
# touch ${INSTROOT}${PATH_STAGING_IMAGE}/usr/lib/.keep

# TODO: Evaluate usefulness of scanning arch since switching to a toolchain sysroot model.
#       Toolchain sysroot *should* be clean.

# If you know a better way to scan architectures of files, please submit an improvement.
# x86 items go by different names in 'file'
scan_arch="${TARGET_ARCH}"
if [[ "${scan_arch}" == "x86_64" ]]; then
    scan_arch="x86-64"
elif [[ "${scan_arch}" == "i"*"86" ]]; then
    scan_arch="Intel 80386"
fi


# WARNING: Copying toolchain libs to staging-sysroot summons dragons:
# rsync -a ${PATH_CROSS_TOOLCHAIN_SYSROOT}/lib/* ${INSTROOT}${PATH_STAGING_SYSROOT}/lib/
# rsync -a ${PATH_CROSS_TOOLCHAIN_SYSROOT}/include/* ${INSTROOT}${PATH_STAGING_SYSROOT}/usr/include/


# Selectively install & strip needed toolchain items to imageprep:
function copylibs() {
    # Arg 1: Directory of lib location
    cd ${1}
    while IFS= read -r -d '' file; do
        if file -b ${file} | grep -iq "${scan_arch}"; then
            echo "* Stripping and installing toolchain item '${file}'"
            ${STRIP} ${STRIP_ARGS} -o ${INSTROOT}${PATH_STAGING_IMAGE}/lib/$(basename ${file}) ${file}

        elif file -b ${file} | grep -q "ASCII"; then
            echo "* Installing ASCII text toolchain item '${file}'"
            cp -a ${file} ${INSTROOT}${PATH_STAGING_IMAGE}/lib/

        else
            echo "* Skipping file ${file}, not an ${scan_arch}-executable item"
        fi
    done < <(find . -name \*.so\* -type f -maxdepth 1 -not  -name \*.py -print0)

    while IFS= read -r -d '' file; do
        intendedtgt=$(basename $(readlink -f ${file}))
        if [ -f ${INSTROOT}${PATH_STAGING_IMAGE}/lib/${intendedtgt} ]; then
            echo "* Ensuring toolchain symlink item '${file}'"
            cp -a ${file} ${INSTROOT}${PATH_STAGING_IMAGE}/lib/

        else
            echo "* Skipping symlink ${file}, destination in rootfs does not exist"
        fi
    done < <(find . -name \*.so\* -type l -maxdepth 1 -not -name \*.py -print0)
}

copylibs ${PATH_CROSS_TOOLCHAIN_SYSROOT}/lib


