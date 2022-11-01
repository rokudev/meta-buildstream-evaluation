kind: autotools

(@):
- include/host-component.yml

depends:
  (>):
  - components/host/libressl.bst
  - components/host/ninja.bst

variables:
  build-dir: build_dir
  # cmake uses a very simplistic configure script
  conf-args: >-
    --prefix=%{prefix}
    --generator=Ninja
  # here's a fun trick:
  make: ninja %{make-args}
  make-install: export DESTDIR=%{install-root}; ninja %{make-args} install

config:
  configure-commands:
    (<):
    - |
      echo 'list(INSERT CMAKE_SYSTEM_LIBRARY_PATH 0 "%{libdir}")' >>Modules/Platform/UnixPaths.cmake
      echo 'list(INSERT CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES 0 "%{libdir}")' >>Modules/Platform/UnixPaths.cmake

sources:
- kind: tar
  url: cmake:v3.24/cmake-3.24.1.tar.gz
  ref: 4931e277a4db1a805f13baa7013a7757a0cbfe5b7932882925c7061d9d1fa82b
- kind: patch_queue
  path: patches/cmake
