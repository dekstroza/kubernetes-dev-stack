include:
   - master.kubernetes


{% set master_ip = salt['grains.get']('master_ip') %}
{% set nfs_ip = salt['grains.get']('nfs_ip') %}

permissive:
    selinux.mode

dekstroza-nfs-server:
  host.present:
    - ip: {{ nfs_ip }}
    - names:
      - nfs
      - nfs.{{ pillar['dns_domain'] }}


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

