kind: manual
description: |
  This is a skeleton rootfs that should have some sane default files.

sources:
  - kind: local
    path: files/base-files
    directory: base-files

build-depends:
  - base/base.bst

variables:
  inst_sysroot: "%{install-root}%{path_staging_sysroot}/"
  inst_image: "%{install-root}%{path_staging_imageprep}/"

  os_release_skel: |
    NAME="%{project_name}"
    VERSION="%{project_version}"
    ID="%{project_name_short}"
    ID_LIKE="busybox"
    PRETTY_NAME="%{project_name} %{project_version}"
    VERSION_ID="%{project_version}"
    HOME_URL="https://no.thank.you"
    BUG_URL="https://no.thank.you"
    SUPPORT_URL="https://no.thank.you"


config:
  # Generate directory structure and symlinks here instead of adding them to source control:
  configure-commands:
    - |
      mkdir -p base-files/{bin,dev,etc,lib/firmware,mnt,root,proc,tmp,sbin,sys}
      mkdir -p base-files/usr/{bin,lib,sbin}
      mkdir -p base-files/dev

    # Note that lib64 -> lib symlinks are handled by 'sysroot-staging.bst'
    - |
      # ln -sfv tmp base-files/var
      ln -sfv . base-files/usr/local

    - |
      ln -sfv ../usr/lib/os-release base-files/etc/os-release

    - |
      chmod 0600 base-files/etc/shadow
      chmod 1777 base-files/tmp

  # Some items we generate at build-time, like os-release:
  build-commands:
    - |
      cat <<EOF >base-files/usr/lib/os-release
      %{os_release_skel}
      EOF

    - |
      sed -i "s#%PATH%#%{path_default}#g" base-files/etc/profile

  # Copy items from base-files to both sysroot and imageprep:
  install-commands:
    - |
      mkdir -p %{inst_sysroot} %{inst_image}
      cp -av base-files/* %{inst_sysroot}/
      cp -av base-files/* %{inst_image}/
