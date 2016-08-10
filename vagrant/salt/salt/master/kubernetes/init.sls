kube-apiserver-config:
   file.managed:
     - name: /etc/kubernetes/apiserver
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/apiserver
     - mode: 644
     - template: jinja

kubernetes-config:
   file.managed:
     - name: /etc/kubernetes/config
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/config
     - mode: 644
     - template: jinja

kube-controller-manager:
   file.managed:
     - name: /etc/kubernetes/controller-manager
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/controller-manager
     - mode: 644
     - template: jinja

kube-scheduler:
 file.managed:
     - name: /etc/kubernetes/scheduler
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/scheduler
     - mode: 644
     - template: jinja

kubelet-config:
   file.managed:
     - name: /etc/kubernetes/kubelet
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/kubelet
     - mode: 644
     - template: jinja

kube-proxy-config:
   file.managed:
     - name: /etc/kubernetes/proxy
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/proxy
     - mode: 644
     - template: jinja

## Configuration file for all auth with api server ##
kubeconfig:
   file.managed:
     - name: /var/lib/kubelet/kubeconfig
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/kubeconfig
     - mode: 644
     - template: jinja
     - makedirs: True
## Token file ##
token.csv:
   file.managed:
     - name: /var/lib/kubernetes/token.csv
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/token.csv
     - mode: 644
     - template: jinja
     - makedirs: True
## Authorization policy file ##
authorization-policy.json:
   file.managed:
     - name: /var/lib/kubernetes/authorization-policy.json
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/authorization-policy.json
     - mode: 644
     - template: jinja
     - makedirs: True


### Cluster services ###
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

kubernetes-dashboard:
  file.managed:
    - name: /etc/kubernetes/kubernetes-dashboard/kubernetes-dashboard.yaml
    - makedirs: True
    - user: root
    - group: root
    - source: salt://master/kubernetes/cluster-addons/kubernetes-dashboard/cfg/kubernetes-dashboard.yaml
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

