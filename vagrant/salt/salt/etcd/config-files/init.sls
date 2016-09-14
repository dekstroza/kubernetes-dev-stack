etcd-config:
   file.managed:
     - name: /etc/etcd/etcd.conf
     - user: root
     - group: root
     - source: salt://etcd/config-files/cfg/etcd.conf
     - mode: 644
     - template: jinja

etcd-network-config:
   file.managed:
     - name: /etc/etcd/network.json
     - user: root
     - group: root
     - source: salt://etcd/config-files/cfg/network.json
     - mode: 644
     - template: jinja
