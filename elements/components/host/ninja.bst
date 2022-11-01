kind: autotools

(@):
- include/host-component.yml

build-depends:
  (>):
  - components/host/python3.bst

sources:
- kind: tar
  url: github-codeload:ninja-build/ninja/tar.gz/v1.11.0?ninja-1.11.0.tar.gz
  ref: 3c6ba2e66400fe3f1ae83deb4b235faf3137ec20bd5b08c29bfc368db143e4c6
- kind: patch_queue
  path: patches/ninja

config:
  configure-commands:
  - python3 ./configure.py --bootstrap --verbose
  
  build-commands:
  - echo "🐱‍👤"

  install-commands:
  - install -D -m 0755 ninja %{install-root}%{bindir}/ninja
