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
docker-systemd-config:
   file.managed:
     - name: /usr/lib/systemd/system/docker.service
     - user: root
     - group: root
     - makedirs: True
     - source: salt://docker/config-files/cfg/docker.service
     - mode: 644
docker-systemd-config-storage:
   file.managed:
     - name: /usr/lib/systemd/system/docker.service.d/docker-storage.conf
     - user: root
     - group: root
     - makedirs: True
     - source: salt://docker/config-files/cfg/docker-storage.conf
     - mode: 644

docker-config-storage-driver:
  cmd.run:
    - name: mkfs.xfs /dev/sdb && mkdir -p /var/lib/docker && mount /dev/sdb /var/lib/docker && systemctl daemon-reload
    - unless: df -T | grep /dev/sdb | grep xfs     
