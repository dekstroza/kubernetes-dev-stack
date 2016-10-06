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
    - require:
      - service: docker
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
      - cmd: generate-certs

kube-proxy-running:
  service.running:
    - name: kube-proxy
    - watch:
      - file: /etc/kubernetes/proxy
    - require:
      - file: /etc/kubernetes/proxy
      - service: kubelet
      - cmd: generate-certs

generate-certs:
  cmd.script:
    - source: salt://master/pre-start-scripts/generate-certs.sh
    - user: root
    - template: jinja

