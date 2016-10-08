include:
   - etcd.config-files

etcd-running:
  service.running:
    - name: etcd
    - watch:
      - file: /etc/etcd/etcd.conf
    - require:
      - file: /etc/etcd/etcd.conf
      - file: /etc/etcd/network.json

configure-cluster-network:
  cmd.run:
    - name: sleep 15 && etcdctl set /coreos.com/network/config < /etc/etcd/network.json
    - require:
      - service: etcd
    - unless: etcdctl get /coreos.com/network/config

