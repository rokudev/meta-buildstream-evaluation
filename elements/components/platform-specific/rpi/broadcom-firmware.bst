kind: make
description: |
  Raspberry Pi Firmware from Broadcom
  Nothing needs to be compiled here, just insert the square bits
    into the square holes and the circular bits into the circular holes.
  
  Still include cross-compile-component.yml however, so we get automatic
    dependencies (e.g. 'path_rootfs' is available)

  This includes the bootloader, and properly installs the kernel to the
    correct name in %{path_rootfs}/boot/
  
  This element will most likely (correctly) error out if built without
    being part of a build with "-o platform rpi" specified.

(@):
- include/cross-compile-component.yml

build-depends:
  (>):
  - components/target/linux.bst

sources:
  - kind: tar
    url: github-public:raspberrypi/firmware/archive/refs/tags/1.20220830.tar.gz
    ref: fcfa24ce0ea26c60d1a140d4220cb803269c38235a08e2b004f458d4692cb97f
  - kind: local
    path: files/platforms/rpi
    directory: our_files

variables:
  dts_tar: "%{path_staging_sysroot}%{path_boot}/%{kernel_arch}_dts.tar.xz"
  # TODO Can we inherit the above variables from linux.bst?

config:
  build-commands:
    # Place everything back in path_staging_sysroot, but in /boot-final
    # Do this so rootfs generation doesn't pick up /boot as well
    - mkdir -p %{install-root}%{path_staging_sysroot}%{path_boot}-final

  install-commands:
    # Install firmware files from rpi firmware tar
    - |
      echo "For platform %{platform_name}, installing these firmware files:"
      for fname in %{firmware-files}; do echo " --> ${fname}"; done

      for fname in %{firmware-files}; do
        install boot/${fname} %{install-root}%{path_staging_sysroot}%{path_boot}-final/
      done

    # Install DTS files from linux's previous install to path_staging_sysroot
    - |
      mkdir dtstemp
      cd dtstemp
      tar xf %{dts_tar}

      echo "For platform %{platform_name}, installing these DTS files:"
      for fname in %{device-dts}; do echo " --> ${fname}"; done

      for fname in %{device-dts}; do
        install ${fname}.dtb %{install-root}%{path_staging_sysroot}%{path_boot}-final/
      done

    # echo "Installing all overlay DTS files:"
    # install dts/overlays/* %{install-root}%{path_staging_sysroot}%{path_boot}-final/overlays/

    # Install kernel image to appropriate Pi bootloader name:
    - install %{path_staging_sysroot}%{path_boot}/vmlinuz %{install-root}%{path_staging_sysroot}%{path_boot}-final/%{pikernelimg}

    # Copy any remaining files:
    - cp -a our_files/* %{install-root}%{path_staging_sysroot}%{path_boot}-final/
