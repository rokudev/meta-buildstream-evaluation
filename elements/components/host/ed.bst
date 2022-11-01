kind: autotools

(@):
- include/host-component.yml

variables:
  conf-local: |
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS"

config:
  install-commands:
    (>):
    - |
      rm "%{install-root}%{infodir}/dir"

public:
  cpe:
    ignored:
    - CVE-2015-2987

sources:
- kind: tar
  url: gnu:ed/ed-1.18.tar.lz
  ref: aca8efad9800c587724a20b97aa8fc47e6b5a47df81606feaba831b074462b4f
