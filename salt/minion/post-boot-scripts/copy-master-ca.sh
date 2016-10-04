#!/bin/bash

{% set master_ip = salt['grains.get']('master_ip') %}

HOST_IP=$(ip -4 -o addr show dev eth0| awk '{split($4,a,"/");print a[1]}')

expect -c "  
set timeout 1
spawn scp edejket@{{ master_ip }}:/var/lib/kubernetes/ca.pem /var/lib/kubernetes/
expect yes/no { send yes\r ; exp_continue }
expect password: { send edejket\r }
expect 100%
sleep 1
exit
"



expect -c "
set timeout 1
spawn scp edejket@{{ master_ip }}:/var/lib/kubelet/kubeconfig /var/lib/kubelet/
expect yes/no { send yes\r ; exp_continue }
expect password: { send edejket\r }
expect 100%
sleep 1
exit
"
expect -c "
set timeout 1
spawn ssh edejket@{{ master_ip }} sudo /usr/sbin/gen-minion-cert.sh $HOST_IP
expect yes/no { send yes\r ; exp_continue }
expect password: { send edejket\r }
expect 100%
sleep 1
exit
"

expect -c "
set timeout 1
spawn scp -r edejket@{{ master_ip }}:/opt/certs/$HOST_IP/* /var/lib/kubernetes/
expect yes/no { send yes\r ; exp_continue }
expect password: { send edejket\r }
expect 100%
sleep 1
exit
"


chmod +r /var/run/kubernetes/ -R
chmod +r /var/lib/kubelet/ -R

