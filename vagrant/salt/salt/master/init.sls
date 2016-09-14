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
      - file: /var/lib/kubelet/kubeconfig
      - file: /var/lib/kubernetes/authorization-policy.json
    - require:
      - service: docker
      - file: /etc/kubernetes/apiserver
      - file: /var/lib/kubelet/kubeconfig
      - file: /var/lib/kubernetes/authorization-policy.json
      - cmd: generate-certs

kube-controller-manager-running:
  service.running:
    - name: kube-controller-manager
    - require:
      - file: /etc/kubernetes/controller-manager
      - file: /var/lib/kubelet/kubeconfig
      - service: kube-apiserver
      - service: docker

kube-scheduler-running:
  service.running:
    - name: kube-scheduler
    - require:
      - file: /etc/kubernetes/scheduler
      - file: /var/lib/kubelet/kubeconfig
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

create-routing-scripts:
  cmd.script:
    - source: salt://master/post-boot-scripts/configure.sh
    - user: root
    - template: jinja
    - require:
      - service: kube-proxy

generate-certs:
  cmd.script:
    - source: salt://master/pre-start-scripts/generate-certs.sh
    - user: root
    - template: jinja

kubectl-setup-root:
  cmd.run:
    - name: kubectl config set-cluster kubernetes --certificate-authority=/var/run/kubernetes/ca.crt  --embed-certs=true --server=https://{{ master_ip }}:6443 && kubectl config set-credentials admin --token chAng3m3 && kubectl config set-context default-context --cluster=kubernetes --user=admin && kubectl config use-context default-context
    - user: root
    - template: jinja
    - require:
      - cmd: generate-certs

kubectl-setup-vagrant:
  cmd.run:
    - name: kubectl config set-cluster kubernetes --certificate-authority=/var/run/kubernetes/ca.crt  --embed-certs=true --server=https://{{ master_ip }}:6443 && kubectl config set-credentials admin --token chAng3m3 && kubectl config set-context default-context --cluster=kubernetes --user=admin && kubectl config use-context default-context
    - user: vagrant
    - template: jinja
    - require:
      - cmd: generate-certs

