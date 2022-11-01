kind: autotools

(@):
- include/cross-compile-component.yml

sources:
- kind: tar
  url: gnu:ncurses/ncurses-6.3.tar.gz
  ref: 97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059
- kind: patch_queue
  path: patches/ncurses

variables:
  conf-local: >-
    --enable-echo
    --enable-const
    --enable-overwrite
    --enable-pc-files
    --disable-rpath
    --without-ada
    --without-debug
    --without-manpages
    --without-profile
    --without-progs
    --without-tests
    --disable-big-core
    --disable-home-terminfo
    --with-normal
    --with-shared
    --with-terminfo-dirs=/usr/share/terminfo
    --with-default-terminfo-dir=/usr/share/terminfo
    --with-pkg-config-libdir=/usr/lib/pkgconfig
    --enable-widec
    --with-build-cppflags=-D_GNU_SOURCE
    cf_try_fPIC=no

  cflags-local: >-
    -fpic

environment:
  PKG_CONFIG_LIBDIR: /usr/lib/pkgconfig
  HOSTCC: "%{host_cc}"
  BUILD_CC: "%{host_cc}"
  HOSTCCFLAGS: ""

# I forgot how annoying ncurses is:
config:
  install-commands:
    (>):
      - |
        echo "** Creating w/ links"
        cd %{destdir}/usr/lib
        for lib in ncurses panel menu form; do
          ln -s lib${lib}w.so lib${lib}.so
        done

        echo "Pruning term list"
        USETERMINFO=%{destdir}/actual/terminfo
        mkdir -p ${USETERMINFO}
        pushd %{destdir}/usr/share/terminfo
        for file in a/ansi d/dumb l/linux p/putty p/putty-256color r/rxvt r/rxvt-unicode s/screen s/screen-256color t/tmux t/tmux-256color v/vt100 v/vt102 x/xterm x/xterm-color x/xterm-256color; do
          [ -f ${file} ] || continue
          mkdir -p ${USETERMINFO}/$(dirname ${file})
          cp -f ${file} ${USETERMINFO}/${file}
        done
        popd
        rm -rf %{destdir}/usr/share/terminfo
        mv ${USETERMINFO} %{destdir}/usr/share/terminfo
                
        mkdir -p %{install-root}%{path_staging_imageprep}/usr/{lib,share}
        cp -av %{destdir}/usr/lib/*.so* %{install-root}%{path_staging_imageprep}/usr/lib/
        cp -av %{destdir}/usr/share/terminfo %{install-root}%{path_staging_imageprep}/usr/share/terminfo
