kind: autotools

(@):
- include/cross-compile-component.yml

sources:
- kind: tar
  url: gnu:readline/readline-8.1.2.tar.gz
  ref: 7589a2381a8419e68654a47623ce7dfcb756815c8fee726b98f90bf668af7bc6
- kind: patch_queue
  path: patches/readline

depends:
  (>):
    - components/target/ncurses.bst

variables:
  conf-local: >-
    --with-curses
    --disable-install-examples
    bash_cv_wcwidth_broken=no
    bash_cv_func_sigsetjmp=yes
  
  cflags-local: >-
    -fpic

config:
  install-commands:
    (>):
      - |
        mkdir -p %{install-root}%{path_staging_imageprep}/usr/lib
        cp -av %{destdir}/usr/lib/lib{history,readline}.so* %{install-root}%{path_staging_imageprep}/usr/lib/
