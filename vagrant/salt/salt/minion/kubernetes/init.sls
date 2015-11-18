kube-config:
   file.managed:
     - name: /etc/kubernetes/config
     - user: root
     - group: root
     - source: salt://minion/kubernetes/cfg/config
     - mode: 644
     - template: jinja

kubelet-config:
   file.managed:
     - name: /etc/kubernetes/kubelet
     - user: root
     - group: root
     - source: salt://minion/kubernetes/cfg/kubelet
     - mode: 644
     - template: jinja

kubectl-config:
   file.managed:
     - name: /root/.kube/config
     - user: root
     - group: root
     - source: salt://minion/kubernetes/cfg/kubectl-config
     - mode: 644
     - template: jinja
     - makedirs: True

kubectl-config-vagrant:
   file.managed:
     - name: /home/vagrant/.kube/config
     - user: vagrant
     - group: vagrant
     - source: salt://minion/kubernetes/cfg/kubectl-config
     - mode: 644
     - template: jinja
     - makedirs: True

