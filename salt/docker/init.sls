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

docker-reload:
  cmd.run:
    - name: systemctl daemon-reload && service docker stop && rm -rf /var/lib/docker/ && service docker start
    - unless: docker info | grep "Storage Driver" | grep "overlay2"
    - require:
      - service: docker


