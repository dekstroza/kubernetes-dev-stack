include:
   - docker.config-files

docker-running:
  service.running:
    - name: docker
    - require:
      - file: docker-systemd-config-storage
      - file: docker-network-config
      - file: docker-systemd-config
      - service: flanneld
      - cmd: docker-config-storage-driver

docker-reload:
  cmd.run:
    - name: service docker restart
    - unless: docker info | grep "Storage Driver" | grep "overlay2"
    - require:
      - service: docker
      - cmd: docker-config-storage-driver


