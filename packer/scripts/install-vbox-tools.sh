#!/bin/bash

mkdir /tmp/isomount
mount -t iso9660 -o loop /home/vagrant/VBoxGuestAdditions.iso /tmp/isomount
cd /tmp/isomount
./VBoxLinuxAdditions.run --nox11 || true
cd /tmp
umount /tmp/isomount
rm -rf /tmp/isomount
yum remove -y gcc bzip2 kernel-ml-devel kernel-ml-headers dkms make perl
yum -y clean all

