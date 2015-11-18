#!/bin/bash

#Clean up and zero swap partition
readonly swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
readonly swappart=$(readlink -f /dev/disk/by-uuid/"$swapuuid")
/sbin/swapoff "$swappart"
dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed" 
/sbin/mkswap -U "$swapuuid" "$swappart"

if [ ! "${PACKER_BUILDER_TYPE}" == "qemu" ]; then
  dd if=/dev/zero of=/EMPTY bs=1M
  rm -f /EMPTY
fi
sync

#Clean and zero disk and boot partition:
rm -rf /var/cache/yum
rm -r /home/vagrant/*.iso
/bin/dd if=/dev/zero of=/boot/EMPTY bs=1M
/bin/rm -f /boot/EMPTY
/bin/dd if=/dev/zero of=/EMPTY bs=1M
/bin/rm -f /EMPTY
sync

