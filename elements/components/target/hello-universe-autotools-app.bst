kind: autotools
description: |
  Part of the "Hello Universe" example, this is a C++ application that
    uses autotools as its build system

(@):
  - include/cross-compile-component.yml

sources:
  - kind: git
    url: github-public:rokudev/example-autotools-app.git
    track: main
    ref: d2aca47368c31f5741ebadd81d459cf5a72e5b0a

depends:
  (>):
    - components/target/hello-universe-autotools-lib.bst

config:
  # NOTE: Here, we are taking from %{bindir} (aka /usr/bin), where our app was installed
  #       to the sysroot, and installing to image_prep's %{sbindir} (aka /usr/sbin)
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}%{sbindir}
        cp -a %{destdir}%{bindir}/* %{install-root}%{path_staging_imageprep}%{sbindir}/
