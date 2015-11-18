#!/bin/bash

echo "####### Updating kubernetes to version 1.1.1 #########"
cd /tmp
curl -L https://github.com/kubernetes/kubernetes/releases/download/v1.1.1/kubernetes.tar.gz -o kubernetes-1.1.1.tar.gz
tar zxvf kubernetes-1.1.1.tar.gz
cd kubernetes/server
tar zxvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
ls | egrep -v "tar|tag" | xargs -I {} cp {} /bin/
cd /tmp/kubernetes/cluster
cp -r addons /etc/
cd /tmp
rm -rf kubernetes
rm -rf kubernetes-1.1.1.tar.gz
echo "####### Updating kubernetes to 1.1.1 Done... #########"

