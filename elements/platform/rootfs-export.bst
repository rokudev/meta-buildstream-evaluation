kind: manual
description: |
  This element provides two tarballs:
    1) %{path_staging_sysroot} tarred up and provided for GDB/Server usage
        - This also adds the C libs in %{path_cross_toolchain_sysroot}
    2) %{path_staging_imageprep} tarred up and provided for whatever
  You should get the resulting tarballs by using the base 'image.bst':
    1) `bst build image.bst`
    2) `bst artifact checkout image.bst`

variables:
  tar_ext: ".tar.xz"
  tar_opts: "-J"
  tar_sysroot: "%{artifact_header}staging-sysroot%{image_suffix}%{tar_ext}"
  tar_imageprep: "%{artifact_header}staging-pre-image%{image_suffix}%{tar_ext}"

build-depends:
- stack.bst

sources:
  - kind: local
    path: files/image/extract-skel.bash

environment:
  XZ_OPT: "-T0"

config:
  install-commands:
    # First, create the big sysroot tar. Need to copy things to combine them.
    # Be sure to copy the "staging_sysroot" first, as it has the directory structure we want.
    # Then after, copy the toolchain sysroot libs and stuff.
    - |
      set -ex
      mkdir sysroot_tar
      cd sysroot_tar

      cp -av %{path_staging_sysroot}/* ./

      cp -av %{path_cross_toolchain_sysroot}/{bin,etc,include,lib,libexec,sbin,share,var} ./

      tar %{tar_opts} -c -f %{install-root}/%{tar_sysroot} *

    # Second, create the imageprep tar from what is currently in imageprep.
    # Might be useful to someone, might not be. Can probably safely disable this step.
    - |
      cd %{path_staging_imageprep}
      tar %{tar_opts} -c -f %{install-root}/%{tar_imageprep} *
      echo
      echo "💎"

    # Make some helper extract scripts:
    - |
      install -m775 extract-skel.bash %{install-root}/extract-sysroot.sh
      install -m775 extract-skel.bash %{install-root}/extract-imageprep.sh

      sed -i 's/extract_name_replace/extract_name="extract_sysroot"/' %{install-root}/extract-sysroot.sh
      sed -i 's/extract_name_replace/extract_name="extract_imageprep"/' %{install-root}/extract-imageprep.sh

      sed -i 's/image_name_replace/image_name="%{tar_sysroot}"/' %{install-root}/extract-sysroot.sh
      sed -i 's/image_name_replace/image_name="%{tar_imageprep}"/' %{install-root}/extract-imageprep.sh
