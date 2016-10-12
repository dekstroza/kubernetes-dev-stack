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
    - name: etcdctl set /coreos.com/network/config < /etc/etcd/network.json
    - watch:
      - file: /etc/etcd/etcd.conf
      - service: etcd
    - require:
      - service: etcd
      - file: /etc/etcd/network.json

