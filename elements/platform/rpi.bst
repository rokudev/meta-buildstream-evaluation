kind: stack
description: |
  Raspberry Pi Platform
  This element simply defines extra packages when using the RPi platform
  List any platform-specific components here: (This list isn't too long... right?)

depends:
- components/target/linux.bst
- components/platform-specific/rpi/broadcom-firmware.bst
