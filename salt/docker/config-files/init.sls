docker-network-config:
  file.managed:
    - name: /etc/sysconfig/docker-network
    - user: root
    - group: root
    - source: salt://docker/config-files/cfg/docker-network.cfg
    - mode: 644
docker-storage-config:
  file.managed:
    - name: /etc/sysconfig/docker-storage
    - user: root
    - group: root
    - source: salt://docker/config-files/cfg/docker-storage.cfg
    - mode: 644
docker-config-storage-driver:
  cmd.run:
    - name: (echo n; echo p; echo 1; echo ; echo ; echo w) | fdisk /dev/vdb && mkfs.ext4 -F /dev/vdb1 && mkdir -p /var/lib/docker && mount /dev/vdb1 /var/lib/docker
    - unless: df -T | grep /dev/vdb1 | grep ext4   
