kind: manual

(@):
- include/cross-compile-component.yml

sources:
- kind: tar
  url: boost:main/release/1.80.0/source/boost_1_80_0.tar.gz
  ref: 4b2136f98bdd1f5857f1c3dea9ac2018effe65286cf251534b6ae20cc45e1847

config:
  build-commands:
    (>):
      - |
        echo "using gcc : `${CC} -dumpversion` : ${CC} : <compileflags>-fPIC <compileflags>-std=gnu++20 ;" > user-config.jam
        ./bootstrap.sh --prefix=%{destdir}/usr
        ./b2 --user-config=user-config.jam install
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}/usr/lib
        cp -av %{destdir}/usr/lib/libboost_*.so* %{install-root}%{path_staging_imageprep}/usr/lib/
