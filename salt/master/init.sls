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
      - service: docker
      - file: /etc/kubernetes/apiserver
      - file: /var/lib/kubernetes/authorization-policy.json
      - cmd: generate-certs

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
      - file: /etc/kubernetes/scheduler
      - service: kube-apiserver
      - service: docker

kubelet:
  service.running:
    - name: kubelet
    - watch:
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
      - file: /var/lib/kubelet/kubeconfig
    - require:
      - service: docker
      - service: kube-apiserver
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
      - file: /var/lib/kubelet/kubeconfig

kube-proxy:
  service.running:
    - name: kube-proxy
    - watch:
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/proxy
      - file: /var/lib/kubelet/kubeconfig
    - require:
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/proxy
      - file: /var/lib/kubelet/kubeconfig
      - service: kubelet

generate-certs:
  cmd.script:
    - source: salt://master/pre-start-scripts/generate-certs.sh
    - user: root
    - template: jinja

generate-minion-cert:
   file.managed:
     - name: /usr/sbin/gen-minion-cert.sh
     - user: root
     - group: root
     - makedirs: True
     - source: salt://master/pre-start-scripts/gen-minion-cert.sh
     - mode: 755

kubectl-setup-root:
  cmd.run:
    - name: kubectl config set-cluster kubernetes --certificate-authority=/var/lib/kubernetes/ca.pem  --embed-certs=true --server=https://{{ master_ip }}:6443 && kubectl config set-credentials admin --token chAng3m3 && kubectl config set-context default-context --cluster=kubernetes --user=admin && kubectl config use-context default-context
    - user: root
    - template: jinja
    - require:
      - cmd: generate-certs

kubectl-setup-edejket:
  cmd.run:
    - name: kubectl config set-cluster kubernetes --certificate-authority=/var/lib/kubernetes/ca.pem  --embed-certs=true --server=https://{{ master_ip }}:6443 && kubectl config set-credentials admin --token chAng3m3 && kubectl config set-context default-context --cluster=kubernetes --user=admin && kubectl config use-context default-context
    - user: edejket
    - template: jinja
    - require:
      - cmd: generate-certs

