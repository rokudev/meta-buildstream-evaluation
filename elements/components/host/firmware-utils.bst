kind: cmake

(@):
- include/host-component.yml

# TODO: Make the dependency on cmake.bst automatic based on 'kind: cmake' above
build-depends:
  (>):
    - components/host/cmake.bst

sources:
- kind: git
  url: openwrt:project/firmware-utils.git
  ref: 0c92b20ad488a4fb5fb290f6d1b893df45761275

