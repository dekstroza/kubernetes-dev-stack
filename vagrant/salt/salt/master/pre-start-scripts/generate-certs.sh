#!/bin/bash

{% set master_ip = salt['grains.get']('master_ip') %}

#yum install -y openssl

cd /opt/easy-rsa-master/easyrsa3
./easyrsa init-pki


./easyrsa --batch "--req-cn={{ master_ip }}@`date +%s`" build-ca nopass
./easyrsa --subject-alt-name="IP:{{ master_ip }},IP:10.0.0.1,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.{{ pillar['dns_domain'] }}" build-server-full kubernetes-master nopass

cp /opt/easy-rsa-master/easyrsa3/pki/ca.crt /var/run/kubernetes/
cp /opt/easy-rsa-master/easyrsa3/pki/private/ca.key /var/run/kubernetes/
cp /opt/easy-rsa-master/easyrsa3/pki/issued/kubernetes-master.crt /var/run/kubernetes/
cp /opt/easy-rsa-master/easyrsa3/pki/private/kubernetes-master.key /var/run/kubernetes/

chmod +r /var/run/kubernetes/ -R
cd

