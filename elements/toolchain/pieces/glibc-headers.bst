kind: autotools
description: gLibC Headers

(@):
- elements/toolchain/pieces/common-glibc.yml

build-depends:
  (>):
  - components/host/python3.bst
  - toolchain/pieces/fake-bootstrap.bst
  - toolchain/pieces/binutils.bst
  - toolchain/pieces/gcc-minimal.bst
  - toolchain/pieces/kernel-headers.bst


variables:
  make-install-targets: >-
    install-bootstrap-headers=yes
    install-headers


config:
  build-commands:
    - echo "Not doing anything :)"

  # Append install-commands -- we need 'install-headers' before this:
  install-commands:
    (>):
    - |
      set -eux
      export %{glibc_confvars}
      %{make} csu/subdir_lib
      mkdir -p %{install-root}%{path_cross_toolchain_sysroot}/usr/{lib,include/gnu}
      install %{build-dir}/csu/{crt1.o,crti.o,crtn.o} %{install-root}/%{path_cross_toolchain_sysroot}/usr/lib/
      %{cross_cc} -nostdlib -nostartfiles -shared -x c /dev/null -o %{install-root}/%{path_cross_toolchain_sysroot}/usr/lib/libc.so
      touch %{install-root}/%{path_cross_toolchain_sysroot}/usr/include/gnu/stubs.h
      rm %{install-root}%{path_cross_toolchain_sysroot}/usr
