kind: compose

build-depends:
- base/fdsdk/filtered.bst
- base/fdsdk/symlinks.bst

sandbox:
  build-arch: '%{host_arch}'
