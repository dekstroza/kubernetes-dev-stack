include:
   - minion.kubernetes.users

var-lib-kubernetes-dir:
   file.directory:
     - name: /var/lib/kubernetes
     - user: kube
     - group: kube
     - makedirs: True
var-run-kubelet-dir:
   file.directory:
     - name: /var/lib/kubelet
     - user: kube
     - group: kube
     - makedirs: True
kubernetes-conf:
   file.managed:
     - name: /usr/lib/tmpfiles.d/kubernetes.conf
     - user: root
     - group: root
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/kubernetes.conf
     - mode: 644
kube-proxy-service:
   file.managed:
     - name: /usr/lib/systemd/system/kube-proxy.service
     - user: root
     - group: root
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/kube-proxy.service
     - mode: 644
kubelet-service:
   file.managed:
     - name: /usr/lib/systemd/system/kubelet.service
     - user: root
     - group: root
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/kubelet.service
     - mode: 644
kubernetes-accounting-conf:
   file.managed:
     - name: /etc/systemd/system.conf.d/kubernetes-accounting.conf
     - user: root
     - group: root
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/kubernetes-accounting.conf
     - mode: 644
kube-config:
   file.managed:
     - name: /etc/kubernetes/config
     - user: root
     - group: root
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/config
     - mode: 644
     - template: jinja

kubelet-config:
   file.managed:
     - name: /etc/kubernetes/kubelet
     - user: root
     - group: root
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/kubelet
     - mode: 644
     - template: jinja

kube-proxy-config:
   file.managed:
     - name: /etc/kubernetes/proxy
     - user: root
     - group: root
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/proxy
     - mode: 644
     - template: jinja

kubectl-config:
   file.managed:
     - name: /root/.kube/config
     - user: root
     - group: root
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/kubectl-config
     - mode: 644
     - template: jinja
     - makedirs: True

kubectl-config-centos:
   file.managed:
     - name: /home/centos/.kube/config
     - user: centos
     - group: centos
     - makedirs: True
     - source: salt://minion/kubernetes/cfg/kubectl-config
     - mode: 644
     - template: jinja
     - makedirs: True

