kind: autotools
description: |
  This builds GDB for the target, but only installs the 'gdbserver' portion

(@):
- include/cross-compile-component.yml
- elements/components/common/gdb.yml

depends:
  (>):
    - components/target/gmp.bst
    - components/target/readline.bst
    - components/target/ncurses.bst
    - components/target/zlib.bst

variables:
  conf-local: >-
    --with-system-readline
    --with-system-zlib
    --without-expat
    --without-lzma
    --disable-unit-tests
    --disable-ubsan
    --disable-sim
    --disable-werror
    --disable-source-highlight
    --without-mpc
    --without-mpfr
    --without-isl
  
  make-install-targets: install-gdbserver

config:
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}/usr/bin
        install %{destdir}/usr/bin/gdbserver %{install-root}%{path_staging_imageprep}/usr/bin/gdbserver
