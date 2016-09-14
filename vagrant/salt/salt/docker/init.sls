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

