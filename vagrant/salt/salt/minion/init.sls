include:
   - minion.flannel
   - minion.docker
   - minion.kubernetes

{% set nfs_ip = salt['grains.get']('nfs_ip') %}

dekstroza-nfs-server:
  host.present:
    - ip: {{ nfs_ip }}
    - names:
      - nfs
      - nfs.{{ pillar['dns_domain'] }}

permissive:
    selinux.mode

firewalld:
  service.dead:
    - name: firewalld
    - enable: false

flannel-running:
  service.running:
    - name: flanneld
    - watch:
      - file: /etc/sysconfig/flanneld
    - require:
      - file: /etc/sysconfig/flanneld

docker-running:
  service.running:
    - name: docker
    - require:
      - file: docker-systemd-config-storage
      - file: docker-network-config
      - file: docker-systemd-config
      - service: flanneld
      - cmd: docker-config-storage-driver

kubelet-running:
  service.running:
    - name: kubelet
    - watch:
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
    - require:
      - service: docker
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
      - cmd: setup-ca-from-master

kube-proxy-running:
  service.running:
    - name: kube-proxy
    - watch:
      - file: /etc/kubernetes/proxy
    - require:
      - file: /etc/kubernetes/proxy
      - service: kubelet
      - cmd: setup-ca-from-master

setup-ca-from-master:
  cmd.script:
    - source: salt://minion/post-boot-scripts/copy-master-ca.sh
    - user: root
    - template: jinja

create-routing-scripts:
  cmd.script:
    - source: salt://minion/post-boot-scripts/configure.sh
    - user: root
    - template: jinja
    - require:
      - service: kube-proxy
