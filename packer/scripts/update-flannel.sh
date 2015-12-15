#!/bin/bash
echo "####### Updating flannel #########"
CWD=`pwd`
cd /tmp
curl -L -k https://github.com/coreos/flannel/releases/download/v0.5.5/flannel-0.5.5-linux-amd64.tar.gz -o flannel-0.5.5-linux-amd64.tar.gz
tar zxvf flannel-0.5.5-linux-amd64.tar.gz
cp -f flannel-0.5.5/flanneld /bin/flanneld
cp -f flannel-0.5.5/mk-docker-opts.sh /usr/libexec/flannel/mk-docker-opts.sh
rm -rf flannel-0.5.5
rm -rf flannel-0.5.5-linux-amd64.tar.gz
echo "####### Flannel update complete #########"
cd $CWD

