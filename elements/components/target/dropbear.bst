kind: autotools

(@):
- include/cross-compile-component.yml

depends:
  (>):
    - components/target/zlib.bst

sources:
- kind: tar
  url: dropbear:releases/dropbear-2022.82.tar.bz2
  ref: 3a038d2bbc02bf28bbdd20c012091f741a3ec5cbe460691811d714876aad75d1

config:
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}/usr
        cp -av %{destdir}/usr/{bin,sbin} %{install-root}%{path_staging_imageprep}/usr/
