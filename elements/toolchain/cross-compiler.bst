kind: stack

# Note: This list does NOT include any temporary pieces,
#       since we don't want to carry that baggage along!
#       Just listing sysroot-staging here is good enough.
depends:
- toolchain/pieces/sysroot-staging.bst

(?):
  - debug == true:
      depends:
        (>):
        - toolchain/pieces/gdb.bst
