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
   file.directory:
     - user: root
     - group: root
     - mode: 777
     - makedirs: True
   file.directory:
     - user: root
     - group: root
     - mode: 777
     - makedirs: True
   file.directory:
     - user: root
     - group: root
     - mode: 777
     - makedirs: True

