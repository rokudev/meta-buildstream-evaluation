kind: autotools

(@):
- include/cross-compile-component.yml
- elements/components/common/gmp.yml

variables:
  conf-local: >-
    --enable-shared
    --enable-static
    --without-readline
    --disable-fft

  cflags-local: >-
    -fpic

config:
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}/usr/lib
        cp -av %{destdir}/usr/lib/libgmp.so* %{install-root}%{path_staging_imageprep}/usr/lib/
