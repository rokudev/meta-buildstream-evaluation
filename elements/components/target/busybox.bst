kind: make
description: Busybox 1.35.0

(@):
- include/cross-compile-component.yml

sources:
- kind: tar
  url: busybox:busybox-1.35.0.tar.bz2
  ref: faeeb244c35a348a334f4a59e44626ee870fb07b6884d68c10ae8bc19f83a694
- kind: local
  path: files/busybox
  directory: hey_heres_some_config_files

variables:
  bbconf-name: busybox-1.35.x-converted.config

  prefix:

  make-args: >-
    CROSS_COMPILE="%{cross_c_prefix}"
    CONFIG_PREFIX="%{destdir}"
    CC="%{cross_cc}"
    LD="%{cross_cc}"
    SKIP_STRIP=y
    V=1

  make-install-args:


environment:
  KCONFIG_NOTIMESTAMP: 1

config:
  configure-commands:
    - |
      cp -av hey_heres_some_config_files/%{bbconf-name} .config
      yes "" | make oldconfig
  
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}
        cp -av %{destdir}/* %{install-root}%{path_staging_imageprep}/
