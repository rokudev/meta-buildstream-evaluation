kind: compose
description: |
  This is the primary element that provides some "image" artifact, whatever
  that may be for the currently given project options. At minimum for the
  default "pristine" platform, it is two tarballs: Unstripped dev sysroot and
  the stripped "pre-image" sysroot that would go into some final platform image.

build-depends:
  - platform/rootfs-export.bst

(?):
  - platform == "rpi":
      build-depends:
        (>):
        - platform/rpi-export.bst
