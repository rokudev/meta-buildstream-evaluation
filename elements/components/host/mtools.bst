kind: autotools

(@):
- include/host-component.yml

sources:
- kind: tar
  url: gnu:mtools/mtools-4.0.40.tar.bz2
  ref: a22fca42354011dd2293a7f51f228b46ebbd802e7740b0975912afecb79d5df4

variables:
  conf-local: >-
    --without-x
    ac_cv_header_iconv_h=no
