kind: cmake

(@):
- include/host-component.yml
- elements/components/common/flatbuffers.yml

# TODO: Make the dependency on cmake.bst automatic based on 'kind: cmake' above
build-depends:
  (>):
    - components/host/cmake.bst
