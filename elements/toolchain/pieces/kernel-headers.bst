kind: make
description: Linux Kernel Headers

(@):
- elements/toolchain/pieces/common-kernel-headers.yml

build-depends:
  (>):
  - components/host/rsync.bst
  - toolchain/pieces/fake-bootstrap.bst

depends:
  (>):
  - toolchain/pieces/binutils.bst
