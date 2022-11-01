kind: autotools

(@):
- include/host-component.yml

build-depends:
  (>):
  - components/host/ed.bst

config:
  install-commands:
    (>):
    - |
      rm "%{install-root}%{infodir}/dir"

sources:
- kind: tar
  url: gnu:bc/bc-1.07.1.tar.gz
  ref: 62adfca89b0a1c0164c2cdca59ca210c1d44c3ffc46daf9931cf4942664cb02a
- kind: patch
  path: patches/bc/add-interpreter-to-script
