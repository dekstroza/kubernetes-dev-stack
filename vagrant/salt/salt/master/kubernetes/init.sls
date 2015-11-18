kube-apiserver-config:
   file.managed:
     - name: /etc/kubernetes/apiserver
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/apiserver
     - mode: 644
     - template: jinja

kube-config:
   file.managed:
     - name: /etc/kubernetes/config
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/config
     - mode: 644
     - template: jinja

kube-controller-manager:
   file.managed:
     - name: /etc/kubernetes/controller-manager
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/controller-manager
     - mode: 644
     - template: jinja

kubelet-config:
   file.managed:
     - name: /etc/kubernetes/kubelet
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/kubelet
     - mode: 644
     - template: jinja

kubectl-config:
   file.managed:
     - name: /root/.kube/config
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/kubectl-config
     - mode: 644
     - template: jinja
     - makedirs: True

kubectl-config-vagrant:
   file.managed:
     - name: /home/vagrant/.kube/config
     - user: vagrant
     - group: vagrant
     - source: salt://master/kubernetes/cfg/kubectl-config
     - mode: 644
     - template: jinja
     - makedirs: True

