kind: manual
description: |
  This generates a helper script, "/xgdb/run", that is intended to be used
    in-sandbox with "bst shell". It uses the special "stack.bst" so we can
    directly use the in-sandbox sysroot

  usage: run <host:port> <executable_path>

  or from host: bst -o <project...options> shell gdb-remote.bst run <host:port> <executable_path>

  You can also mount a GDB history file by adding "--mount ~/somestoragedir /history"
    to the "bst shell" args.

  For example:
  $ bst -o target_arch aarch64 -o debug true shell gdb-remote.bst run 192.168.1.25:9000 /bin/busybox



(?):
  - debug == false:
      (!): |
        Cannot use gdb-remote if -o debug is not set to true!


depends:
  - stack.bst

environment:
  PATH: "/xgdb:%{path_cross_toolchain}/bin:%{path_default}"
  STAGING_DIR: "%{path_cross_toolchain}"

variables:
  gdb_config_file: "gdb.config"
  gdb_script_file: "run"

  # Optionally mount a directory for gdb.history to live in:
  # bst shell --mount ~/bst_gdb_history /history
  gdb_hist_file: "/history/gdb.history"

  # This is a script in-sandbox that auto-configures GDB on-execution:
  gdb_script_skel: |
    #/usr/bin/env sh
    # Arg 1: host:port
    # Arg 2: target executable path

    [ \$# -ne 2 ] && echo "ERROR: usage: \$0 host:port target/exec/path" && exit 9

    set -eu

    export PATH=%{path_cross_toolchain}/bin:${PATH}
    export STAGING_DIR=%{path_cross_toolchain}
    touch %{gdb_hist_file}

    cat <<EOS >%{gdb_config_file}
    set history filename %{gdb_hist_file}
    set history size 100000000
    set history save on
    set sysroot %{path_staging_sysroot}
    target extended-remote \${1}
    EOS

    %{cross_gdb} -x %{gdb_config_file} -f %{path_staging_sysroot}/\${2}

config:
  # "Building" this element simply installs the above script:
  build-commands:
    - |
      mkdir -p %{install-root}/xgdb
      cat <<EOF >%{install-root}/xgdb/%{gdb_script_file}
      %{gdb_script_skel}
      EOF
      chmod +x %{install-root}/xgdb/%{gdb_script_file}
