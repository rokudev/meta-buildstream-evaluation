kind: autotools
description: |
  Part of the "Hello Universe" example, this is a C++ library that
    uses autotools as its build system

(@):
  - include/cross-compile-component.yml

sources:
  - kind: git
    url: github-public:rokudev/example-autotools-lib.git
    track: main
    ref: 42c8af16ce67cae8c52f5d301489c8c135aad203

config:
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}%{libdir}
        cp -a %{destdir}%{libdir}/*.so* %{install-root}%{path_staging_imageprep}%{libdir}/
