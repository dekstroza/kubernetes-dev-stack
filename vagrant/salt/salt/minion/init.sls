include:
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

kubelet-running:
  service.running:
    - name: kubelet
    - watch:
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
      - service: docker
    - require:
      - service: docker
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
      - cmd: setup-ca-from-master

kube-proxy-running:
  service.running:
    - name: kube-proxy
    - watch:
      - service: docker
      - file: /etc/kubernetes/proxy
    - require:
      - file: /etc/kubernetes/proxy
      - service: kubelet
      - service: docker
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
