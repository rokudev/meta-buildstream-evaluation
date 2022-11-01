kind: stack
description: |
  The Pristine platform is a virtual platform that should only differ in target_arch
  Place your global components to be cross-compiled for ALL platforms in the depends list:

depends:
- base/base.bst
- toolchain/cross-compiler.bst
- components/target/base-files.bst
- components/target/busybox.bst
- components/target/rsync.bst
- components/target/hello-world.bst

(?):
  - debug == true:
      depends:
        (>):
        - components/target/gdbserver.bst
        - components/target/dropbear.bst
