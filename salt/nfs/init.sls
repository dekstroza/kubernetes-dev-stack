
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

nfs-config-exports:
   file.managed:
     - name: /etc/exports
     - user: root
     - group: root
     - source: salt://nfs/cfg/exports
     - mode: 644
     - template: jinja

/opt/docker-registry:
   file.directory:
     - user: root
     - group: root
     - mode: 777
     - makedirs: True

create-nfs-partition:
  cmd.run:
    - name: (echo n; echo p; echo 1; echo ; echo ; echo w) | fdisk /dev/vdc && mkfs.ext4 -F /dev/vdc && mkdir -p /opt/enm && mount /dev/vdc1 /opt/enm
    - unless: df -T | grep /dev/vdc1 | grep ext4

