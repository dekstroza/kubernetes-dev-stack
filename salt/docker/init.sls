include:
   - docker.config-files

docker-running:
  service.running:
    - name: docker
    - require:
      - file: docker-network-config
      - file: docker-storage-config
      - service: flanneld

