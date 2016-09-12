#!/bin/bash

KUBERNETES_VERSION="1.3.6"

echo "####### Updating kubernetes #########"
mkdir -p /opt/kubernetes && cd /opt/kubernetes

curl -L -O https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kube-apiserver
curl -L -O https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kube-controller-manager
curl -L -O https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kube-scheduler
curl -L -O https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl
curl -L -O https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kube-proxy
curl -L -O https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubelet
curl -L -O https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kube-dns

chmod +x /opt/kubernetes/ -R

mv -f /opt/kubernetes/kube* /usr/bin/ && cd /opt/ && rm -rf /opt/kubernetes
echo "###### Updating kubernetes done ####"

echo "### Installing easy-rsa Done ... ###"
cd /opt/
curl -L -O https://storage.googleapis.com/kubernetes-release/easy-rsa/easy-rsa.tar.gz
tar xzf easy-rsa.tar.gz
rm -rf /opt/easy-rsa.tar.gz
echo "### Done Installing easy-rsa ####"

