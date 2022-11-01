kind: make
description: Linux Kernel!

# Includes: CCC.yml MUST come first -- we are overriding some items.
(@):
- include/cross-compile-component.yml
- elements/components/common/linux.yml

build-depends:
  (>):
  - components/host/rsync.bst
  - components/host/bc.bst
  # perl, already in FDSDK

variables:
  linux_version: "5.15"

  path_our_kstuff: "%{build-root}/stuff4bst"
  path_configs: "%{path_our_kstuff}/configs-%{linux_version}"
  path_config_global: "%{path_configs}/generic"
  path_config_socfam: "%{path_configs}/%{kernel_soc_family}/generic"
  path_config_socind: "%{path_configs}/%{kernel_soc_family}/%{kernel_soc_name}"
  path_config: "%{build-root}/.config"
  kcpl: "%{path_our_kstuff}/kconfig.pl"

  kmakeflags: >-
    ARCH=%{kernel_arch}
    CROSS_COMPILE=%{cross_c_prefix}
    V=1

  strip-binaries: |
    echo "Not stripping kernel modules"
    echo "  (I mean I can, but it would probably make them useless)"


environment:
  ARCH: "%{kernel_arch}"
  # compile.h has hardcoded timestamp, let's seed it
  KBUILD_BUILD_TIMESTAMP: 'Thu Nov 10 15:00:00 UTC 2011'
  KBUILD_BUILD_USER: 'popcorn'
  KBUILD_BUILD_HOST: 'buildstream'
  KBUILD_BUILD_VERSION: "0"
  KBUILD_HAVE_NLS: 'no'
  V: 1

config:
  configure-commands:
    # Linux Kernel Config is inspired from OpenWrt's method of handling 2000 different
    #   routers in their build system. Figured it was a good starting point for us.
    #   See: https://github.com/openwrt/openwrt/blob/master/include/kernel-defaults.mk
    #        https://github.com/openwrt/openwrt/tree/master/target/linux
    # From files/linux/configs-%{linux_version}:
    # Apply 'generic' here first -- this config applies to ALL kernels
    # Go to %{kernel_soc_family} subdir.
    # Apply 'generic' there next, if there is one -- this config applies to all kernels within this SoC family
    # Apply '%{kernel_soc_name}' there next, if there is one -- this config applies to this specific SoC
    # From all these, combine in-order and generate a .config
    - |
      rm -f localversion
      set -e
      oper=""
      comb="%{path_config_global}"
      if [ -f %{path_config_socfam} ]; then
        oper+=" +"
        comb+=" %{path_config_socfam}"
      fi
      if [ -f %{path_config_socind} ]; then
        oper+=" +"
        comb+=" %{path_config_socind}"
      fi
      if [ "x${oper}" != "x" ]; then
        echo "** Running: %{kcpl}${oper} ${comb} > %{path_config}"
        %{kcpl}${oper} ${comb} > %{path_config}
      else
        cp -a %{path_config_global} %{path_config}
      fi
      cp %{path_config} %{path_config}.combostrike

    - |
      make %{kmakeflags} -j1 olddefconfig
      grep '=[ym]' %{path_config} | LC_ALL=C sort | md5sum > .vermagic

  build-commands:
    - |
      make %{kmakeflags}

  install-commands:
    # Kernel modules, vmlinux, System.map, Module.symvers, magnets, how do they work
    - |
      krealver=$(make %{kmakeflags} -j1 kernelversion)
      kmoddir=%{destdir}/lib/modules/${krealver}
      echo "~+=== got krealver -> ${krealver}"
      echo "~+=== got kmoddir  -> ${kmoddir}"
      mkdir -p ${kmoddir}
      touch ${kmoddir}/.kmod_locator

      while IFS= read -r -d '' file; do
        echo "~+=== installing found kmod: ${file}"
        install -Dm644 ${file} ${kmoddir}/$(basename ${file})
      done < <(find %{build-root} -name *.ko -print0)

      mkdir -p %{install-root}%{path_staging_imageprep}/lib/modules
      cp -a ${kmoddir} %{install-root}%{path_staging_imageprep}/lib/modules/

    - |
      mkdir -p %{destdir}%{path_boot}/image
      install -Dm644 vmlinu* %{destdir}%{path_boot}/image/
      install -Dm644 "%{kernel_imgname}" %{destdir}%{path_boot}/vmlinuz
      install -Dm644 System.map %{destdir}%{path_boot}/System.map
      install -Dm644 Module.symvers %{destdir}%{path_boot}/Module.symvers
      install -Dm644 %{path_config} %{destdir}%{path_boot}/config-%{linux_version}
      install -Dm644 %{path_config}.combostrike %{destdir}%{path_boot}/config-%{linux_version}-orig

    # For DTS files: Assuming we don't know anything about platform, just copy them all
    - |
      if [ -d "%{kernel_dtsdir}" ]; then
        echo "~+=== Packaging DTS Files"
        cd %{kernel_dtsdir}
        tar cJf %{destdir}%{path_boot}/%{kernel_arch}_dts.tar.xz ./*
      else
        echo "~+=== No DTS Files to Package!"
      fi
