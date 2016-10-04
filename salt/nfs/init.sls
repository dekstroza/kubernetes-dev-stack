
rpcbind-running:
  service.running:
    - name: rpcbind

nfs-running:
  service.running:
    - name: nfs 
    - watch:
      - file: /etc/exports
    - require:
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

