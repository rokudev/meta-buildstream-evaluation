kind: make
description: |
  Building a sample makefile app
  See what the defaults for 'make' kind are:
    https://github.com/apache/buildstream-plugins/blob/master/src/buildstream_plugins/elements/make.yaml
  Do note that 'include/cross-compile-component.yml' overrides some items, like DESTDIR.

(@):
- include/cross-compile-component.yml

sources:
  - kind: local
    path: sources/hello-world

variables:
  strip-exclude: >-
    hello_app_stay_unstripped

config:
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}/usr/sbin
        cp -av %{destdir}/usr/bin/hello_app %{install-root}%{path_staging_imageprep}/usr/sbin/
        cp -av %{destdir}/usr/bin/hello_app %{install-root}%{path_staging_imageprep}/usr/sbin/hello_app_stay_unstripped

