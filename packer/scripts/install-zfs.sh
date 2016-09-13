#!/bin/bash

yum -y localinstall http://download.zfsonlinux.org/epel/zfs-release$(rpm -E %dist).noarch.rpm
rpm -ivh http://elrepo.org/linux/kernel/el7/x86_64/RPMS/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum -y --enablerepo=elrepo-kernel install kernel-ml-devel kernel-ml-headers gcc
rpm -ivh ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/Kenzy:/modified:/C7/CentOS_7/noarch/dkms-2.2.0.3-31.1.noarch.rpm
yum -y --disablerepo zfs --enablerepo=zfs-testing install zfs
modprobe zfs
yum -y clean all


