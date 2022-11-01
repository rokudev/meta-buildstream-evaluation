kind: autotools
description: |
  OpenBSD LibreSSL, as a drop-in replacement for OpenSSL for those
  pesky host tools that need crypto libs (*cough* CMake *cough*)

(@):
- include/host-component.yml

sources:
- kind: tar
  url: openbsd:OpenBSD/LibreSSL/libressl-3.5.3.tar.gz
  ref: 3ab5e5eaef69ce20c6b170ee64d785b42235f48f2e62b095fca5d7b6672b8b28

variables:
  # Only provide as static library.
  # CMake has a weird issue using the shared library that I don't care to debug.
  conf-local: >-
    --disable-shared
    --enable-static
    --disable-asm
    --with-pic
    --disable-tests
  
  cflags-local: >-
    -fPIC

config:
  install-commands:
    (>):
      - rm -rf %{install-root}%{prefix}/share/man
