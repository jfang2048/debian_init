#!/bin/bash

sudo virsh destroy preseedtest01
sudo virsh undefine preseedtest01 --nvram

sudo rm -r /var/lib/libvirt/images/preseed_system.qcow2
sudo rm -r /var/lib/libvirt/images/preseed_data.qcow2
sudo rm -r auto-debian.iso
sudo rm -r /var/lib/libvirt/images/auto-debian.iso

sudo /bin/bash make_iso_by_preseed.sh

sudo mv auto-debian.iso /var/lib/libvirt/images/

sudo virt-install \
  --name preseedtest01 \
  --memory 2048 \
  --vcpus=2 \
  --disk path=/var/lib/libvirt/images/preseed_data.qcow2,size=200,format=qcow2,cache=none,bus=sata,target.dev=sda \
  --disk path=/var/lib/libvirt/images/preseed_system.qcow2,size=50,format=qcow2,cache=none,bus=virtio,target.dev=vda \
  --cdrom /var/lib/libvirt/images/auto-debian.iso \
  --os-variant debian11 \
  --network bridge:virbr0 \
  --video qxl \
  --channel spicevmc \
  --graphics spice,listen=0.0.0.0,password=000000 \
  --boot uefi

  #--disk /var/lib/libvirt/images/preseed_system.qcow2,size=500,format=qcow2,cache=none \
  #--disk /var/lib/libvirt/images/preseed_data.qcow2,size=2000,format=qcow2,cache=none \
  
