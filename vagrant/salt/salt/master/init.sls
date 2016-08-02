include:
   - master.etcd
   - master.flannel
   - master.docker
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
      - file: /var/lib/kubelet/kubeconfig
      - file: /var/lib/kubernetes/authorization-policy.json
    - require:
      - service: docker
      - file: /etc/kubernetes/apiserver
      - file: /var/lib/kubelet/kubeconfig
      - file: /var/lib/kubernetes/authorization-policy.json
      - cmd: correct-kube-dir-privs
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

run-kube-dns:
  cmd.run:
    - name: kube-dns --domain={{ pillar['dns_domain'] }} --kube-master-url=https://{{ master_ip }}:6443 --kubecfg-file=/var/lib/kubelet/kubeconfig > /dev/null 2>&1 &
    - require:
      - service: kube-apiserver
      - file: /var/lib/kubelet/kubeconfig
    - unless: pidof kube-dns


correct-kube-dir-privs:
  cmd.run:
    - name: mkdir -p /var/run/kubernetes && chown kube:kube /var/run/kubernetes/ -R
    - unless: ls -ld /var/run/kubernetes | awk '{print $3}' | grep kube

