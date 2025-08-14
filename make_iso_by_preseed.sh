#!/bin/bash

check_packages() {
    local packages=("isolinux" "syslinux")
    local missing=()
    
    for pkg in "${packages[@]}"; do
        if ! dpkg -s "$pkg" &> /dev/null; then
            missing+=("$pkg")
        fi
    done
    
    echo "${missing[@]}"
}

missing_packages=$(check_packages)

if [ -n "$missing_packages" ]; then
    sudo apt update
    sudo apt install -y $missing_packages
fi

if [ -d isofiles/ ]; then
  rm -rf isofiles/*
fi

# xorriso -osirrox on -indev debian-12.8.0-amd64-DVD-1.iso -extract / isofiles/
xorriso -osirrox on -indev /home/jfang/Downloads/debian-12.11.0-amd64-DVD-1.iso -extract / isofiles/

sudo cp -f grub.cfg isofiles/boot/grub/grub.cfg

chmod +w -R isofiles/install.amd
gunzip isofiles/install.amd/initrd.gz
echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.amd/initrd

gzip isofiles/install.amd/initrd
chmod -w -R isofiles/install.amd

chmod a+x -R isofiles/
chmod a+w isofiles/md5sum.txt

cd isofiles/
md5sum `find -follow -type f` > md5sum.txt
cd ..
chmod a-w isofiles/md5sum.txt

xorriso -as mkisofs \
    -V "CUSTOM_ISO" \
    -o auto-debian.iso \
    -r -J -l -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    isofiles

sudo rm -rf isofiles/ 
