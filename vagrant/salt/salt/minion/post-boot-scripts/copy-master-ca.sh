#!/bin/bash

{% set master_ip = salt['grains.get']('master_ip') %}

expect -c "  
   set timeout 1
   spawn scp vagrant@{{ master_ip }}:/var/run/kubernetes/ca.crt /var/run/kubernetes/
   expect yes/no { send yes\r ; exp_continue }
   expect password: { send vagrant\r }
   expect 100%
   sleep 1
   exit
"

  

expect -c "
   set timeout 1
   spawn scp vagrant@{{ master_ip }}:/var/lib/kubelet/kubeconfig /var/lib/kubelet/
   expect yes/no { send yes\r ; exp_continue }
   expect password: { send vagrant\r }
   expect 100%
   sleep 1
   exit
"
chmod +r /var/run/kubernetes/ -R
chmod +r /var/lib/kubelet/ -R

