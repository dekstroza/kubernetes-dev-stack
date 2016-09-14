include:
   - flannel.config-files
   - etcd

flannel-running:
  service.running:
    - name: flanneld
    - watch:
      - file: /etc/sysconfig/flanneld
    - require:
      - service: etcd
      - file: /etc/sysconfig/flanneld
      - cmd: configure-cluster-network
