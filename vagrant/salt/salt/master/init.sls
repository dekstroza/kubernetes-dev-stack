include:
   - master.etcd
   - master.flannel
   - master.docker
   - master.kubernetes


{% set master_ip = salt['grains.get']('master_ip') %}

permissive:
    selinux.mode

firewalld:
  service.dead:
    - name: firewalld
    - enable: false

etcd-running:
  service.running:
    - name: etcd
    - watch:
      - file: /etc/etcd/etcd.conf
    - require:
      - file: /etc/etcd/etcd.conf
      - file: /etc/etcd/network.json

flannel-running:
  service.running:
    - name: flanneld
    - watch:
      - file: /etc/sysconfig/flanneld
    - require:
      - service: etcd
      - file: /etc/sysconfig/flanneld
      - cmd: configure-cluster-network

configure-cluster-network:
  cmd.run:
    - name: sleep 10 && etcdctl set /coreos.com/network/config < /etc/etcd/network.json
    - require:
      - service: etcd
    - unless: etcdctl get /coreos.com/network/config


docker-running:
  service.running:
    - name: docker
    - require:
      - file: docker-config
      - file: docker-network-config
      - service: flanneld

kube-apiserver-running:
  service.running:
    - name: kube-apiserver
    - watch:
      - file: /etc/kubernetes/apiserver
    - require:
      - service: docker
      - file: /etc/kubernetes/apiserver
      - cmd: correct-kube-dir-privs

kube-controller-manager-running:
  service.running:
    - name: kube-controller-manager
    - require:
      - file: /etc/kubernetes/controller-manager
      - service: kube-apiserver
      - service: docker

kube-scheduler-running:
  service.running:
    - name: kube-scheduler
    - require:
      - service: kube-apiserver
      - service: docker

kubelet:
  service.running:
    - name: kubelet
    - watch:
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
    - require:
      - service: docker
      - service: kube-apiserver
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet

kube-proxy:
  service.running:
    - name: kube-proxy
    - watch:
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
    - require:
      - service: kubelet

run-kube-dns:
  cmd.run:
    - name: kubectl -s {{ master_ip }}:8080 create -f /etc/kubernetes/dns/
    - require:
      - service: kube-proxy
      - file: /etc/kubernetes/dns/skydns-rc.yaml
      - file: /etc/kubernetes/dns/skydns-svc.yaml
    - unless: kubectl -s {{ master_ip }}:8080 get rc --namespace=kube-system | grep dns


correct-kube-dir-privs:
  cmd.run:
    - name: mkdir -p /var/run/kubernetes && chown kube:kube /var/run/kubernetes/ -R
    - unless: ls -ld /var/run/kubernetes | awk '{print $3}' | grep kube

dns-rc-setup:
  file.managed:
    - name: /etc/kubernetes/dns/skydns-rc.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/dns/cfg/skydns-rc.yaml
    - template: jinja
    - require:
      - service: kube-proxy

dns-svc-setup:
  file.managed:
    - name: /etc/kubernetes/dns/skydns-svc.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/dns/cfg/skydns-svc.yaml
    - template: jinja
    - require:
      - service: kube-proxy

kubeui-rc-setup:
  file.managed:
    - name: /etc/kubernetes/kube-ui/kube-ui-rc.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/kube-ui/cfg/kube-ui-rc.yaml
    - template: jinja
    - require:
      - service: kube-proxy

kubeui-svc-setup:
  file.managed:
    - name: /etc/kubernetes/kube-ui/kube-ui-svc.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/kube-ui/cfg/kube-ui-svc.yaml
    - template: jinja
    - require:
      - service: kube-proxy

kube-grafana-servicesetup:
  file.managed:
    - name: /etc/kubernetes/grafana/grafana-service.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/grafana/cfg/grafana-service.yaml
    - template: jinja
    - require:
      - service: kube-proxy 

kube-grafana-heapster-controller:
  file.managed:
    - name: /etc/kubernetes/grafana/heapster-controller.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/grafana/cfg/heapster-controller.yaml
    - template: jinja
    - require:
      - service: kube-proxy

kube-grafana-heapster-svc:
  file.managed:
    - name: /etc/kubernetes/grafana/heapster-service.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/grafana/cfg/heapster-service.yaml
    - template: jinja
    - require:
      - service: kube-proxy

kube-grafana-influx-rc:
  file.managed:
    - name: /etc/kubernetes/grafana/influxdb-grafana-controller.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/grafana/cfg/influxdb-grafana-controller.yaml
    - template: jinja
    - require:
      - service: kube-proxy

kube-grafana-influx-svc:
  file.managed:
    - name: /etc/kubernetes/grafana/influxdb-service.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/grafana/cfg/influxdb-service.yaml
    - template: jinja
    - require:
      - service: kube-proxy

registry-svc:
  file.managed:
    - name: /etc/kubernetes/registry/registry-svc.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/registry/registry-svc.yaml
    - template: jinja
    - require:
      - service: kube-proxy

registry-rc:
  file.managed:
    - name: /etc/kubernetes/registry/registry-rc.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/registry/registry-rc.yaml
    - template: jinja
    - require:
      - service: kube-proxy

registry-pv:
  file.managed:
    - name: /etc/kubernetes/registry/registry-pv.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/registry/registry-pv.yaml
    - template: jinja
    - require:
      - service: kube-proxy

registry-pvc:
  file.managed:
    - name: /etc/kubernetes/registry/registry-pvc.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/registry/registry-pvc.yaml
    - template: jinja
    - require:
      - service: kube-proxy

cluster-load-balancing-svc:
  file.managed:
    - name: /etc/kubernetes/cluster-loadbalancing/default-svc.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/cluster-loadbalancing/default-svc.yaml
    - template: jinja
    - require:
      - service: kube-proxy

cluster-load-balancing-rc:
  file.managed:
    - name: /etc/kubernetes/cluster-loadbalancing/glbc-controller.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/cluster-loadbalancing/glbc-controller.yaml
    - template: jinja
    - require:
      - service: kube-proxy

