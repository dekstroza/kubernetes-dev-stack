#!/bin/bash
{% set master_ip = salt['grains.get']('master_ip') %}

### add route command for OSX ###
echo -e "sudo route -n delete {{ pillar['service_cluster_cidr'] }}" > /edejket/add-route-osX.sh 
echo -e "sudo route -n add {{ pillar['service_cluster_cidr'] }} {{ master_ip }}" >> /edejket/add-route-osX.sh
chmod +x /edejket/add-route-osX.sh

### add route command for LINUX ###
echo -e "sudo route del -net {{ pillar['service_cluster_cidr'] }}" > /edejket/add-route-LIN.sh
echo -e "sudo route add -net {{ pillar['service_cluster_cidr'] }} gw {{ master_ip }}" >> /edejket/add-route-LIN.sh
chmod +x /edejket/add-route-LIN.sh

### add route command for WINDOWS ###
echo -e "route delete {{ pillar['service_cluster_cidr'] }} mask 255.255.0.0 & route add {{ pillar['service_cluster_cidr'] }} mask 255.255.0.0  {{ master_ip }}" > /edejket/add-route-WIN.bat
echo -e "MASTER IP: {{ master_ip }}"

