kind: cmake
description: |
  Part of the "Hello Universe" example, this is a C++ library that
    uses CMake as its build system

(@):
  - include/cross-compile-component.yml
  - include/cmake-cross-compile-hack.yml

sources:
  - kind: git
    url: github-public:rokudev/example-cmake-lib.git
    track: main
    ref: 458e2d03ffa1fa3aace64290d3cd8c32f2ff8b7f

config:
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}%{libdir}
        cp -a %{destdir}%{libdir}/*.so* %{install-root}%{path_staging_imageprep}%{libdir}/
