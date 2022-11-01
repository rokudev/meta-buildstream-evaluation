kind: manual
description: |
  How do you get artifacts out of BuildStream?
  BST has a heavier focus on caching. Any built element results in a cached artifact.
  So, if you simply want a tarball of the toolchain, you need to run two commands:
    1) `bst -o target_arch <arch> build toolchain/export.bst`
    2) `bst -o target_arch <arch> artifact checkout toolchain/export.bst`
  By default, the second command will place your tarball in a directory similarly
    named to the element. Here, the `toolchain/export` directory.
    See `bst artifact checkout --help` for options.
  You can run `bst artifact checkout` on any element to examine the files an element
    installs, or use `bst artifact list-contents` to just get a file list.

build-depends:
- toolchain/cross-compiler.bst

sources:
  - kind: local
    path: files/image

variables:
  tar_ext: ".tar.xz"
  tar_opts: "-J -P --transform \"s,%{path_cross_toolchain}/,,\""
  tar_toolchain: "RBSTc_%{target_triplet_full}_forhost_%{host_triplet}%{tar_ext}"
  info_file: "toolchain.info"
  info_skel: |
    # Toolchain built by BuildStream
    ARCH="%{target_arch}"
    CROSS_COMPILE="%{cross_c_prefix}"
    TARGET_TRIPLET="%{target_triplet_full}"
    HOST_ARCH="%{host_arch}"
    HOST_TRIPLET="%{host_triplet_full}"
    GDB_PATH="bin/%{cross_gdb}"
    GCC_VERSION="12.2.0"
    LIBC_TYPE="glibc"
    LIBC_VERSION="2.35"
    LIBC_SO_VERSION="2.35"

  # TODO: How to pull these values from toolchain/pieces/*.bst?
  # GCC_VERSION="%{gcc_version}"


environment:
  XZ_OPT: "-T0"

config:
  build-commands:
    # Create toolchain info file
    - |
      cat <<EOF >%{info_file}
      %{info_skel}
      EOF

  install-commands:
    - |
      tar %{tar_opts} -c -f %{install-root}/%{tar_toolchain} %{info_file} %{path_cross_toolchain}/*
      stat %{install-root}/%{tar_toolchain}
      echo
      echo "CONTENTS:"
      tar tf %{install-root}/%{tar_toolchain}
      echo
    
    # Make a helper extract script:
    - |
      install -m775 extract-skel.bash %{install-root}/extract-toolchain.sh
      sed -i 's/extract_name_replace/extract_name="extract_toolchain"/' %{install-root}/extract-toolchain.sh
      sed -i 's/image_name_replace/image_name="%{tar_toolchain}"/' %{install-root}/extract-toolchain.sh
