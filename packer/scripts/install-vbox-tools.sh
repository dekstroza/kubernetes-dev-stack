#!/bin/bash

case "$PACKER_BUILDER_TYPE" in
	virtualbox-iso|virtualbox-ovf)
		mkdir /tmp/isomount
		mount -t iso9660 -o loop /home/vagrant/VBoxGuestAdditions.iso /tmp/isomount
		cd /tmp/isomount
		./VBoxLinuxAdditions.run --nox11 || true
		cd /tmp
		umount /tmp/isomount
		rm -rf /tmp/isomount
		rm -rf /home/vagrant/VBoxGuestAdditions.iso
		yum remove -y gcc bzip2 kernel-ml-devel kernel-ml-headers kernel-ml-tools-libs dkms perl selinux-policy-devel
		yum -y install openssl
		yum -y clean all
		;;

	parallels-iso|parallels-pvm)
		mkdir /tmp/parallels
		mount -o loop /home/vagrant/prl-tools-lin.iso /tmp/parallels
		/tmp/parallels/install --install-unattended-with-deps
		umount /tmp/parallels
		rmdir /tmp/parallels
		rm -rf /home/vagrant/*.iso
		yum remove -y gcc bzip2 kernel-ml-devel kernel-ml-headers dkms make perl selinux-policy-devel
		yum -y install openssl
		yum -y clean all
		;;

	*)
		echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
		echo "Known are virtualbox-iso|virtualbox-ovf|parallels-iso|parallels-pvm."
		;;
esac

