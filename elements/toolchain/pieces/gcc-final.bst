kind: autotools
description: GCC Final

(@):
- elements/toolchain/pieces/common-gcc.yml

build-depends:
  (>):
  - components/host/python3.bst
  - toolchain/pieces/fake-bootstrap.bst
  - toolchain/pieces/gcc-initial.bst

depends:
  (>):
  - toolchain/pieces/binutils.bst
  - toolchain/pieces/kernel-headers.bst
  - toolchain/pieces/glibc.bst


config:
  install-commands:
    - |
      set -eux
      mkdir -p %{install-root}%{path_cross_toolchain_sysroot}/{lib,include}

      rm -rf %{install-root}%{path_cross_toolchain}/%{target_triplet_full}/sys-include
      ln -sfv ../include %{install-root}%{path_cross_toolchain}/%{target_triplet_full}/sys-include
      
      rm -rf %{install-root}%{path_cross_toolchain}/%{target_triplet_full}/lib
      ln -sfv sysroot/lib %{install-root}%{path_cross_toolchain}/%{target_triplet_full}/lib
      ln -sfv lib %{install-root}%{path_cross_toolchain}/%{target_triplet_full}/lib32
      if [[ "%{target_arch_is_64}" == "true" ]]; then
        ln -sfv lib %{install-root}%{path_cross_toolchain}/%{target_triplet_full}/lib64
      fi
      
      %{make-install}
      
      rm %{install-root}%{path_cross_toolchain}/%{target_triplet_full}/sys-include

      ln -sfv %{cross_cc} %{install-root}%{path_cross_toolchain}/bin/%{cross_c_prefix}cc

      rm -rf %{install-root}%{path_cross_toolchain}/share/man

      /rbst/system/patch-specs.sh %{install-root}%{path_cross_toolchain}

      %{get_little_helpers}
      FixupLibdir %{install-root}%{path_cross_toolchain_sysroot}
      TripletSymlinks %{install-root}%{path_cross_toolchain} %{target_triplet_full} %{target_triplet}
      