kind: manual
description: |
  This is a special element that prepares our toolchain for our cross-compiling
  development staging %{path_staging_sysroot} and final installable %{path_rootfs}

sources:
- kind: local
  path: files/toolchain

(@):
- elements/toolchain/pieces/common-all.yml

depends:
  (>):
  - toolchain/pieces/gcc-final.bst

build-depends:
  (>):
  - components/host/rsync.bst


environment:
  INSTROOT: "%{install-root}"
  # Copy items from toolchain sysroot:
  PATH_CROSS_TOOLCHAIN_SYSROOT: "%{path_cross_toolchain_sysroot}"
  # To staging sysroot unstripped:
  PATH_STAGING_SYSROOT: "%{path_staging_sysroot}"
  # And to staging imageprep stripped:
  PATH_STAGING_IMAGE: "%{path_staging_imageprep}"

  TARGET_ARCH: "%{target_arch}"
  STRIP: "%{cross_strip}"
  STRIP_ARGS: "%{strip_args}"

config:
  # Test that our new toolchain actually works
  configure-commands:
    - |
      set -eux
      %{cross_cc} -v
      echo 'int main(){}' | %{cross_cc} -xc -
      %{cross_readelf} -l a.out | grep ld-linux

      %{cross_cc} %{target_cflags} -DTESTSTRING=\"cross\" %{target_ldflags} test.c -o test.out
      file ./test.out
      %{cross_objdump} -x ./test.out | grep NEEDED
      rm -f test.out

  build-commands:
    - chmod +x ./toolchain-staging.sh
    - sh -c ./toolchain-staging.sh
  
  install-commands:
  # Do a final symlink from our full triplet to the short triplet:
    - mkdir -p %{install-root}%{path_cross_toolchain}/
    - ln -sfv %{target_triplet_full} %{install-root}%{path_cross_toolchain}/%{target_triplet}
