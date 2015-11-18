docker-config:
  file.managed:
    - name: /etc/sysconfig/docker
    - user: root
    - group: root
    - source: salt://master/docker/cfg/docker.cfg
    - mode: 644

docker-network-config:
  file.managed:
    - name: /etc/sysconfig/docker-network
    - user: root
    - group: root
    - source: salt://master/docker/cfg/docker-network.cfg
    - mode: 644

docker-storage-config:
  file.managed:
    - name: /etc/sysconfig/docker-storage
    - user: root
    - group: root
    - source: salt://master/docker/cfg/docker-storage.cfg
    - mode: 644

