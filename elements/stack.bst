kind: stack
description: |
  The "stack" element should be the primary source of truth
  for what elements are included in the rootfs "stack".
  Should be "pristine", and then whatever platform-specific things.
  Any imaging elements should directly depend on "stack.bst"

depends:
  - platform/pristine.bst

# Platform-specific components should be specified here:
(?):
  - platform == "rpi":
      depends:
        (>):
        - platform/rpi.bst


# Most likely usage is with 'bst shell', so for convenience:
environment:
  STAGING_DIR: "%{path_cross_toolchain}"
  PATH: "%{path_cross_toolchain}/bin:%{path_default}"
