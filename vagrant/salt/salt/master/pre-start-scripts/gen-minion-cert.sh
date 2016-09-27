#!/bin/bash

MINION_IP=$1

mkdir -p /opt/certs/$MINION_IP && cd /opt/certs/$MINION_IP

echo '{
"CN": "kubernetes",
"hosts": [
"MINION_IP"
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
}' > $MINION_IP-csr.json

sed -i "s/MINION_IP/$MINION_IP/g" $MINION_IP-csr.json

cfssl gencert \
	-ca=../root-ca/ca.pem \
	-ca-key=../root-ca/ca-key.pem \
	-config=../ca-config.json \
	-profile=kubernetes \
	$MINION_IP-csr.json | cfssljson -bare kubernetes

chmod +r /opt/certs/$MINION_IP/ -R


