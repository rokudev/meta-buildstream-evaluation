kind: autotools
description: |
  This is a cross GDB that isn't *technically* a toolchain item, but
  is compiled along with it if 'debug' mode is specified
  (or if you directly build this element)

(@):
- elements/toolchain/pieces/common-all.yml
- elements/components/common/gdb.yml


build-depends:
  (>):
    - components/host/gmp.bst

depends:
  (>):
    - components/host/python3.bst

#     - components/host/readline.bst
#     - components/host/ncurses.bst
#     - components/host/zlib.bst

variables:
  conf-args: >-
    --build=%{host_triplet_full}
    --host=%{host_triplet_full}
    --target=%{target_triplet_full}
    --prefix=%{path_cross_toolchain}
    --with-pkgversion="%{toolchain_name} GDB"
    --disable-binutils
    --disable-gas
    --disable-gdbtk
    --disable-gprof
    --disable-ld
    --disable-sim
    --disable-ubsan
    --disable-unit-tests
    --disable-werror
    --enable-threads
    --enable-tui
    --with-python=python3
    --without-expat
    --without-included-gettext
    --without-uiout
    --without-x

environment:
  CXXFLAGS: "-fpic -O2"

config:
  install-commands:
    (>):
      - |
        rm %{install-root}%{path_cross_toolchain}/share/info/{bfd.info,ctf-spec.info,dir}

