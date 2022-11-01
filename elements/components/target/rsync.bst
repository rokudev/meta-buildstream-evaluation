kind: autotools

(@):
- include/cross-compile-component.yml
- elements/components/common/rsync.yml

config:
  install-commands:
    (>):
      - |
        cp -av %{destdir}/* %{install-root}%{path_staging_imageprep}/
