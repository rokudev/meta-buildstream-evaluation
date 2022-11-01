kind: filter

(?):
- host_arch == "x86_64":
    depends:
    - filename: base/fdsdk/fdsdk-x86_64.bst
      type: build
- host_arch == "aarch64":
    depends:
    - filename: base/fdsdk/fdsdk-aarch64.bst
      type: build

config:
  exclude:
    - filter
  include-orphans: True

public:
  bst:
    integration-commands:
    - |
      mv /usr/etc /etc
