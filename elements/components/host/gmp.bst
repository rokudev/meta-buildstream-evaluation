kind: autotools

(@):
- include/host-component.yml
- elements/components/common/gmp.yml

variables:
  conf-local: >-
    --enable-static
    --disable-shared
    --disable-assembly
    --enable-cxx
