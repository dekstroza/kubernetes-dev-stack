#!/bin/bash

{% set master_ip = salt['grains.get']('master_ip') %}

mkdir /opt/certs && cd /opt/certs

echo '{
"signing": {
"default": {
"expiry": "8760h"
    },
    "profiles": {
    "kubernetes": {
    "usages": ["signing", "key encipherment", "server auth", "client auth"],
    "expiry": "8760h"
      }
    }
  }
}' > ca-config.json

echo '{
"CN": "Kubernetes",
"key": {
"algo": "rsa",
"size": 2048
  },
  "names": [
  {
	  "C": "IE",
	  "L": "Athlone",
	  "O": "Kubernetes",
	  "OU": "CA",
	  "ST": "Westmeath"
  }
  ]
}' > ca-csr.json

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
mkdir root-ca
mv ca-key.pem root-ca/
mv ca.csr root-ca/
mv ca.pem root-ca/

mkdir kube-master
echo '{
"CN": "kubernetes",
"hosts": [
"10.0.0.1",
"{{ master_ip }}"
],
"key": {
"algo": "rsa",
"size": 2048
  },
  "names": [
  {
	  "C": "IE",
	  "L": "Athlone",
	  "O": "Kubernetes",
	  "OU": "Cluster",
	  "ST": "Westmeath"
  }
  ]
}' > kube-master/kubernetes-csr.json

cd kube-master
cfssl gencert \
	-ca=../root-ca/ca.pem \
	-ca-key=../root-ca/ca-key.pem \
	-config=../ca-config.json \
	-profile=kubernetes \
	../kube-master/kubernetes-csr.json | cfssljson -bare kubernetes
cd ..

mkdir -p /var/lib/kubernetes

cp root-ca/ca.csr /var/lib/kubernetes/
cp root-ca/ca-key.pem /var/lib/kubernetes/
cp root-ca/ca.pem /var/lib/kubernetes/
cp kube-master/kubernetes-key.pem /var/lib/kubernetes/
cp kube-master/kubernetes.csr /var/lib/kubernetes/
cp kube-master/kubernetes.pem /var/lib/kubernetes/
chmod +r /var/lib/kubernetes/ -R

