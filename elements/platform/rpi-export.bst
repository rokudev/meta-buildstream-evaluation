kind: manual
description: |
  Raspberry Pi Platform
  This element combines everything, then runs final SDCard imaging
  You should get the resulting images by using the base 'image.bst':
    1) `bst build image.bst`
    2) `bst artifact checkout image.bst`

(@):
- include/rootfs/ext4.yml

build-depends:
# Stack.bst should be the primary source of truth for platform packages
- stack.bst
# Any host tools needed for building images go here:
- components/host/dosfstools.bst      # For mkfs.fat for boot partition
- components/host/mtools.bst          # For mcopy
- components/host/make-ext4fs.bst     # For rootfs
- components/host/firmware-utils.bst  # For ptgen in sdcard script


# Sources here are for imaging scripts (Wanna guess where I stole that from too?)
sources:
  - kind: local
    path: files/platforms/rpi


variables:
  final_sd_img_name: "%{artifact_header}rpi-sdcard%{image_suffix}.img"
  inter_img_boot: rbst_rpi_bootpart.fat
  inter_img_root: rbst_rpi_rootpart.rootfs
  # Sizes in MB:
  fat32_block_size: 1024
  bootfs_sz: 64 
  rootfs_sz: 104
  rootfs_blksz: 4096

  # For RPi, the fat32 boot partition is a unique thing, so manually doing that here.
  # For the rootfs, will use common rootfs include streams in 'include/rootfs/{ext4,squashfs}.yml'
  #
  # Final arg is blocks, so %{bootfs_sz}*1024*1024 for bytes / block size
  # Should come out to 65536 for 64MB bootfs_sz at 1024 blksz
  mkfs_boot: >-
    mkfs.fat
    -n boot
    -C %{inter_img_boot}
    $(echo $((%{bootfs_sz}*1024*1024/%{fat32_block_size})))
  
  copy2boot_cmd: mcopy -v -i %{build-root}/%{inter_img_boot}

  boot_copydir: "%{path_staging_sysroot}%{path_boot}-final"

  # $0 <file> <bootfs image> <rootfs image> <bootfs size> <rootfs size>
  rpi_sdcard_scr_cmd: >-
    ./gen_rpi_sdcard_img.sh
    %{install-root}/%{final_sd_img_name}
    %{inter_img_boot}
    %{inter_img_root}
    %{bootfs_sz}
    %{rootfs_sz}

config:
  # Create boot and rootfs partition images here:
  build-commands:
    - |
      [ -e %{inter_img_boot} -o -e %{inter_img_root} ] && echo "ERROR: existing?" && exit 45
      set -eux
      %{mkfs_boot}

      while IFS= read -r -d '' file; do
        relpath="${file#%{boot_copydir}}"
        reldir="$(dirname ${relpath})"
        [[ reldir == "/" ]] && reldir=""
        echo "~~ Copying '${file}' (as '${relpath}' to '${reldir}') to boot part"
        %{copy2boot_cmd} ${file} ::${reldir}
      done < <(find %{boot_copydir} -type f -print0)

      %{mkfs_root}

  # Combine them into an SD card image here.
  # GZip afterwords, otherwise it'll be huge.
  install-commands:
    - |
      set -eux
      %{rpi_sdcard_scr_cmd}
      gzip %{install-root}/%{final_sd_img_name}
      set +x
      echo
      echo "🥧"
