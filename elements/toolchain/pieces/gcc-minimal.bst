kind: autotools
description: GCC Minimal

(@):
- elements/toolchain/pieces/common-gcc.yml

build-depends:
  (>):
  - toolchain/pieces/fake-bootstrap.bst
  - toolchain/pieces/binutils.bst


variables:
  make-targets: "all-gcc"
  make-install-targets: "install-gcc"


config:
  install-commands:
    (>):
    - |
      rm -rf %{install-root}%{path_cross_toolchain}/share/man
      %{get_little_helpers}
      TripletSymlinks %{install-root}%{path_cross_toolchain} %{target_triplet_full} %{target_triplet}
