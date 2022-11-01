kind: cmake

(@):
- include/cross-compile-component.yml
- include/cmake-cross-compile-hack.yml

sources:
- kind: git
  url: github-public:madler/zlib.git
  ref: 21767c654d31d2dccdde4330529775c6c5fd5389
- kind: patch_queue
  path: patches/zlib

config:
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}%{libdir}
        cp -av %{destdir}%{libdir}/*.so* %{install-root}%{path_staging_imageprep}%{libdir}/
