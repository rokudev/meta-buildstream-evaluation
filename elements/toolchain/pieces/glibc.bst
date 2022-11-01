kind: autotools
description: gLibC Final

(@):
- elements/toolchain/pieces/common-glibc.yml

build-depends:
  (>):
  - components/host/python3.bst
  - toolchain/pieces/fake-bootstrap.bst
  - toolchain/pieces/gcc-initial.bst
  - toolchain/pieces/glibc-headers.bst

depends:
  (>):
  - toolchain/pieces/binutils.bst
  - toolchain/pieces/kernel-headers.bst


variables:
  make-args: >-
    default-rpath="/lib:/usr/lib"
  make-targets: all


config:
  install-commands:
    (>):
    - |
      rm -f %{install-root}%{path_cross_toolchain}/share/info/dir
      rm %{install-root}%{path_cross_toolchain_sysroot}/usr
