kind: cmake

(@):
- include/cross-compile-component.yml
- include/cmake-cross-compile-hack.yml
- elements/components/common/flatbuffers.yml

variables:
  cmake-local: -DFLATBUFFERS_BUILD_TESTS=OFF
