kind: cmake

(@):
- include/cross-compile-component.yml
- include/cmake-cross-compile-hack.yml

# NOTE: Changed to open-source version of rostd: https://github.com/rokudev/rostd
sources:
- kind: git
  url: github-public:rokudev/rostd
  track: main
  ref: e8f2be882f88c2e367caec7e3db218bb1274d354

config:
  # rostd doesn't have an install target, so we need to manually copy headers
  install-commands:
    - mkdir -p %{install-root}%{path_staging_sysroot}%{includedir}
    - cp -av include/rostd %{install-root}%{path_staging_sysroot}%{includedir}/
