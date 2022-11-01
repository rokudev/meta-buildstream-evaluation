kind: cmake
description: |
  Part of the "Hello Universe" example, this is a C++ application that
    uses CMake as its build system

(@):
  - include/cross-compile-component.yml
  - include/cmake-cross-compile-hack.yml

sources:
  - kind: git
    url: github-public:rokudev/example-cmake-app.git
    track: main
    ref: 93e6884bced3b673a0e92382ed027733f8216526

depends:
  (>):
    - components/target/hello-universe-autotools-lib.bst
    - components/target/hello-universe-cmake-lib.bst

config:
  # NOTE: Here, we are taking from %{bindir} (aka /usr/bin), where our app was installed
  #       to the sysroot, and installing to image_prep's %{sbindir} (aka /usr/sbin)
  install-commands:
    (>):
      - |-
        mkdir -p %{install-root}%{path_staging_imageprep}%{sbindir}
        cp -a %{destdir}%{bindir}/* %{install-root}%{path_staging_imageprep}%{sbindir}/
