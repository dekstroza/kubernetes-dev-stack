#!/bin/bash

VERSION="0.7.0"
echo "####### Updating flannel to version $VERSION #########"
CWD=`pwd`
cd /tmp
curl -L -k https://github.com/coreos/flannel/releases/download/v$VERSION/flannel-v$VERSION-linux-amd64.tar.gz -o flannel-$VERSION-linux-amd64.tar.gz
tar zxvf flannel-$VERSION-linux-amd64.tar.gz
cp -f flanneld /bin/flanneld
cp -f mk-docker-opts.sh /usr/libexec/flannel/mk-docker-opts.sh
rm -rf flannel-$VERSION
rm -rf flannel-$VERSION-linux-amd64.tar.gz
echo "####### Flannel update complete #########"
cd $CWD

