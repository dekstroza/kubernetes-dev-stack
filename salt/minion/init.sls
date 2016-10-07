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
      - file: /var/lib/kubelet/kubeconfig
    - require:
      - service: docker
      - file: /etc/kubernetes/config
      - file: /etc/kubernetes/kubelet
      - file: /var/lib/kubelet/kubeconfig
      - cmd: generate-certs

kube-proxy-running:
  service.running:
    - name: kube-proxy
    - watch:
      - file: /etc/kubernetes/proxy
      - file: /var/lib/kubelet/kubeconfig
    - require:
      - file: /etc/kubernetes/proxy
      - file: /var/lib/kubelet/kubeconfig
      - service: docker
      - cmd: generate-certs

generate-certs:
  cmd.script:
    - source: salt://master/pre-start-scripts/generate-certs.sh
    - user: root
    - template: jinja

