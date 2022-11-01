kind: autotools
description: GCC Initial

(@):
- elements/toolchain/pieces/common-gcc.yml

build-depends:
  (>):
  - toolchain/pieces/fake-bootstrap.bst
  - toolchain/pieces/binutils.bst
  - toolchain/pieces/gcc-minimal.bst
  - toolchain/pieces/kernel-headers.bst
  - toolchain/pieces/glibc-headers.bst


variables:
  make-targets: "all-build-libiberty all-gcc all-target-libgcc"
  make-install-targets: "install-gcc install-target-libgcc"


config:
  # GlibC after this starts requiring paths to be correct, so
  #   do our symlinking actions here:
  install-commands:
    (>):
    - |
      rm -rf %{install-root}%{path_cross_toolchain}/share/man

      %{get_little_helpers}
      TripletSymlinks %{install-root}%{path_cross_toolchain} %{target_triplet_full} %{target_triplet}
      FixupLibdir %{install-root}%{path_cross_toolchain}/%{target_triplet_full}
