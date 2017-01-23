#!/bin/bash

KUBERNETES_VERSION="1.5.2"

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

echo "###### Installing cfs tools ######"
curl -L -O https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
curl -L -O https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssljson_linux-amd64
chmod +x cfssl_linux-amd64
mv cfssl_linux-amd64 /usr/bin/cfssl
mv cfssljson_linux-amd64 /usr/bin/cfssljson
echo "###### Installing cfs tools done ####"

