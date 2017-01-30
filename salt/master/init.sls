include:
   - master.kubernetes


{% set master_ip = salt['grains.get']('master_ip') %}
{% set nfs_ip = salt['grains.get']('nfs_ip') %}

permissive:
    selinux.mode

firewalld:
  service.dead:
    - name: firewalld
    - enable: false

kube-apiserver-running:
  service.running:
    - name: kube-apiserver
    - watch:
      - file: /etc/kubernetes/apiserver
      - file: /var/lib/kubernetes/authorization-policy.json
    - require:
      - file: /etc/kubernetes/apiserver
      - file: /var/lib/kubernetes/authorization-policy.json
      - cmd: generate-certs

kube-controller-manager-running:
  service.running:
    - name: kube-controller-manager
    - require:
      - service: kube-apiserver
      - file: /etc/kubernetes/controller-manager

kube-scheduler-running:
  service.running:
    - name: kube-scheduler
    - require:
      - service: kube-apiserver
      - file: /etc/kubernetes/scheduler

kubelet:
  service.running:
    - name: kubelet
    - require:
      - service: docker
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
      - file: /var/lib/kubelet/kubeconfig
      - cmd: generate-certs

kube-proxy:
  service.running:
    - name: kube-proxy
    - require:
      - service: docker
      - service: kubelet
      - file: /etc/kubernetes/proxy
      - file: /var/lib/kubelet/kubeconfig
      - cmd: generate-certs

generate-certs:
  cmd.script:
    - source: salt://master/pre-start-scripts/generate-certs.sh
    - user: root
    - template: jinja

kubectl-setup-root:
  cmd.run:
    - name: kubectl config set-cluster kubernetes --certificate-authority=/var/lib/kubernetes/ca.pem  --embed-certs=true --server=https://{{ master_ip }}:6443 && kubectl config set-credentials admin --token chAng3m3 && kubectl config set-context default-context --cluster=kubernetes --user=admin && kubectl config use-context default-context
    - user: root
    - template: jinja
    - require:
      - cmd: generate-certs

kubectl-setup-centos:
  cmd.run:
    - name: kubectl config set-cluster kubernetes --certificate-authority=/var/lib/kubernetes/ca.pem  --embed-certs=true --server=https://{{ master_ip }}:6443 && kubectl config set-credentials admin --token chAng3m3 && kubectl config set-context default-context --cluster=kubernetes --user=admin && kubectl config use-context default-context
    - user: centos
    - template: jinja
    - require:
      - cmd: generate-certs

reload-flannel-tmp-fix:
  cmd.run:
    - name: service flanneld restart
    - require:
      - cmd: run-dns
      - service: docker
      - service: flanneld
      - service: etcd
      - service: kubelet
      - service: kube-proxy
label-master-node-nfs:
  cmd.run:
    - name: kubectl label nodes {{ master_ip }} nfs-node=true
    - require:
      - service: kube-apiserver
      - service: kube-controller-manager
      - service: kube-scheduler
      - service: kubelet
      - service: kube-proxy
      - cmd: kubectl-setup-root
run-dns:
  cmd.run:
    - name: kubectl create -f /etc/kubernetes/dns/
    - user: {{ pillar['cloud-user'] }}
    - unless: kubectl get po --namespace=kube-system | grep dns > /dev/null 2>&1
    - require:
      - file: /etc/kubernetes/dns/skydns-rc.yaml
      - file: /etc/kubernetes/dns/skydns-svc.yaml
      - service: kube-apiserver
      - service: kube-controller-manager
      - service: kube-scheduler
run-dashboard:
  cmd.run:
    - name: kubectl create -f /etc/kubernetes/kubernetes-dashboard/
    - user: {{ pillar['cloud-user'] }}
    - unless: kubectl get po --namespace=kube-system | grep dashboard > /dev/null 2>&1
    - require:
      - file: /etc/kubernetes/kubernetes-dashboard/kubernetes-dashboard-rc.yaml
      - file: /etc/kubernetes/kubernetes-dashboard/kubernetes-dashboard-svc.yaml
      - service: kube-apiserver
      - service: kube-controller-manager
      - service: kube-scheduler
run-grafana:
  cmd.run:
    - name: kubectl create -f /etc/kubernetes/grafana/
    - user: {{ pillar['cloud-user'] }}
    - unless: kubectl get po --namespace=kube-system | grep "influx|grafana|heapster" > /dev/null 2>&1
    - require:
      - file: /etc/kubernetes/grafana/grafana-service.yaml
      - file: /etc/kubernetes/grafana/heapster-controller.yaml
      - file: /etc/kubernetes/grafana/heapster-service.yaml
      - file: /etc/kubernetes/grafana/influxdb-grafana-controller.yaml
      - file: /etc/kubernetes/grafana/influxdb-service.yaml
      - service: kube-apiserver
      - service: kube-controller-manager
      - service: kube-scheduler

