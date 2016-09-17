include:
   - docker.config-files

docker-running:
  service.running:
    - name: docker
    - require:
      - service: flanneld
      - cmd: reload-systemd-config

clear-graph-driver:
  cmd.run:
    - name: rm -rf /var/lib/docker
    - unless: docker info | grep "Deferred Removal Enabled" | grep "true"

configure-lvm-storage:
  cmd.run:
    - unless: vgdisplay | grep docker
    - require:
      - file: configure-storage-lvm-profile
      - cmd: clear-graph-driver
    - name: pvcreate /dev/sdb && vgcreate docker /dev/sdb && lvcreate --wipesignatures y -n thinpool docker -l 95%VG &&  lvcreate --wipesignatures y -n thinpoolmeta docker -l 1%VG && lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta && lvchange --metadataprofile docker-thinpool docker/thinpool

reload-systemd-config:
  cmd.run:
    - name: systemctl daemon-reload
    - require:
      - cmd: configure-lvm-storage
      - file: docker-systemd-config-storage
      - file: docker-network-config
      - file: docker-storage-config
      - file: docker-systemd-config
