kind: manual
description: |
  This element sanitizes our sandbox, and ensures that the temporary `host_vendor` triplet is available.
  This is similar to crosstool-ng's "Making build system tools available" stage
  This element is only visible during toolchain pieces compile, and should not be used otherwise.

(@):
- elements/toolchain/pieces/common-all.yml

sources:
- kind: local
  path: files/toolchain/test.c

config:
  build-commands:
    # Create symlinks for our fake bootstrap triplet -- install directly in /usr/bin where real gcc is
    - |
      mkdir -p %{install-root}/usr/{bin,lib/gcc,libexec/gcc}
      parts=("ar" "as" "cpp" "gcc" "gcc-ar" "gcc-nm" "gcc-ranlib" "g++" "ld" "libtool" "nm" "objcopy" "objdump" "ranlib" "size" "strings" "strip")
      for item in "${parts[@]}"; do
        if command -v $item; then
          ln -svf $(command -v $item) %{install-root}/usr/bin/%{host_triplet_full}-$item
        else
          echo "ERROR: Host does not provide $item"
          exit 1
        fi
      done
      original_triplet=$(basename /usr/%{host_arch}*)
      ln -svf ${original_triplet} %{install-root}/usr/%{host_triplet_full}
      ln -svf ${original_triplet} %{install-root}/usr/lib/gcc/%{host_triplet_full}
      ln -svf ${original_triplet} %{install-root}/usr/libexec/gcc/%{host_triplet_full}
      cxxstuff=$(realpath /usr/include/c++/*/)
      mkdir -p %{install-root}/${cxxstuff}
      ln -svf ${original_triplet} %{install-root}${cxxstuff}/%{host_triplet_full}
    # Sanity check our bootstrap gcc. Should be already-provided %{host_cc} and related vars
    # Compile a trivial program, static build, and static link libstdc++
    - |
      set -eux
      export PATH=%{install-root}/usr/bin:${PATH}
      %{host_cc} -v
      %{host_cc} %{host_cflags} -DTESTSTRING=\"trivial\" %{host_ldflags} test.c -o test.out
      file ./test.out
      ./test.out
      ldd ./test.out
      rm -f test.out
      %{host_cc} %{host_cflags} -DTESTSTRING=\"static\" %{host_ldflags} test.c -static -o test.out
      file ./test.out
      ./test.out
      ldd ./test.out && false || true
      rm -f test.out
      %{host_cc} %{host_cflags} -DTESTSTRING="\"static libstdc++\"" %{host_ldflags} test.c -static -lstdc++ -o test.out
      file ./test.out
      ./test.out
      ldd ./test.out && false || true
      rm -f test.out
    # Because GCC/binutils/etc are going to be a pain otherwise:
    # - |
    #   mkdir -p %{install-root}%{path_tools}
    #   ln -sf %{install-root}%{path_toolchains} %{install-root}%{path_toolchains}



