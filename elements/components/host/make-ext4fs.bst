kind: make

(@):
- include/host-component.yml

sources:
- kind: git
  url: openwrt:project/make_ext4fs.git
  ref: 5c201be7d72aff735da27e17c29852e0cefe3e52

config:
  install-commands:
    - install -D -m 0755 make_ext4fs %{install-root}%{bindir}/make_ext4fs
