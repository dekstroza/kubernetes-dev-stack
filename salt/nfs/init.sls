{% set master_ip = salt['grains.get']('master_ip') %}
{% set nfs_ip = salt['grains.get']('nfs_ip') %}

nfs-server-alias:
  host.present:
    - ip: {{ nfs_ip }}
    - names:
      - nfs
      - nfs.{{ pillar['dns_domain'] }}

rpcbind-running:
  service.running:
    - name: rpcbind

nfs-running:
  service.running:
    - name: nfs 
    - watch:
      - file: /etc/exports
    - require:
      - cmd: create-nfs-partition
      - file: /etc/exports
      - file: /opt/docker-registry
      - file: /opt/enm/versant_data
      - file: /opt/enm/models
      - file: /opt/enm/dps
nfs-config-exports:
   file.managed:
     - name: /etc/exports
     - user: root
     - group: root
     - source: salt://nfs/cfg/exports
     - mode: 644
     - template: jinja
     - require:
       - cmd: create-nfs-partition

/opt/docker-registry:
   file.directory:
     - user: root
     - group: root
     - mode: 777
     - makedirs: True
     - require:
       - cmd: create-nfs-partition
/opt/enm/versant_data:
   file.directory:
     - user: root
     - group: root
     - mode: 777
     - makedirs: True
     - require:
       - cmd: create-nfs-partition
/opt/enm/models:
   file.directory:
     - user: root
     - group: root
     - mode: 777
     - makedirs: True
     - require:
       - cmd: create-nfs-partition
/opt/enm/dps:
   file.directory:
     - user: root
     - group: root
     - mode: 777
     - makedirs: True
     - require:
       - cmd: create-nfs-partition
     
create-nfs-partition:
  cmd.run:
    - name: (echo n; echo p; echo 1; echo ; echo ; echo w) | fdisk /dev/vdc && mkfs.ext4 -F /dev/vdc1 && mkdir -p /opt/enm && mount /dev/vdc1 /opt/enm
    - unless: df -T | grep /dev/vdc1 | grep ext4

