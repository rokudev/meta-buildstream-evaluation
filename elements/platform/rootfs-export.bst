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
  tar_ext: ".xz"
  tar_opts: '-p --sort=name --mtime="@${SOURCE_DATE_EPOCH}" --warning=no-file-changed'
  tar_sysroot: "%{artifact_header}staging-sysroot%{image_suffix}.tar"
  tar_imageprep: "%{artifact_header}staging-pre-image%{image_suffix}.tar"

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
    # Some host filesystems may throw "file-changed" warnings with error code 1. It's ok, trust me bro.
    - |
      set -x
      set +e
      cd %{path_staging_sysroot}
      tar -c -f %{install-root}/%{tar_sysroot} %{tar_opts} *
      ret=$?
      if [ $ret -ne 0 ] && [ $ret -ne 1 ]; then
        echo "tar exited with $ret"
        exit $ret
      fi

      cd %{path_cross_toolchain_sysroot}
      tar -A -f %{install-root}/%{tar_sysroot} %{tar_opts} bin etc include lib libexec sbin share var
      ret=$?
      if [ $ret -ne 0 ] || [ $ret -ne 1 ]; then
        echo "tar exited with $ret"
        exit $ret
      fi

      xz -z ${XZ_OPT} %{install-root}/%{tar_sysroot}

    # tar -c -f %{install-root}/%{tar_sysroot} %{tar_opts} --xform="s#%{path_staging_sysroot}/##" %{path_staging_sysroot}/*
    # Second, create the imageprep tar from what is currently in imageprep.
    # Might be useful to someone, might not be. Can probably safely disable this step.
    - |
      set -x
      set +e
      cd %{path_staging_imageprep}

      tar -c -f %{install-root}/%{tar_imageprep} %{tar_opts} *
      ret=$?
      if [ $ret -ne 0 ] && [ $ret -ne 1 ]; then
        echo "tar exited with $ret"
        exit $ret
      fi

      xz -z ${XZ_OPT} %{install-root}/%{tar_imageprep}
      echo
      echo "💎"

    # Make some helper extract scripts:
    - |
      install -m775 extract-skel.bash %{install-root}/extract-sysroot.sh
      install -m775 extract-skel.bash %{install-root}/extract-imageprep.sh

      sed -i 's/extract_name_replace/extract_name="extract_sysroot"/' %{install-root}/extract-sysroot.sh
      sed -i 's/extract_name_replace/extract_name="extract_imageprep"/' %{install-root}/extract-imageprep.sh

      sed -i 's/image_name_replace/image_name="%{tar_sysroot}%{tar_ext}"/' %{install-root}/extract-sysroot.sh
      sed -i 's/image_name_replace/image_name="%{tar_imageprep}%{tar_ext}"/' %{install-root}/extract-imageprep.sh
