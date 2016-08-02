kube-apiserver-config:
   file.managed:
     - name: /etc/kubernetes/apiserver
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/apiserver
     - mode: 644
     - template: jinja

kubernetes-config:
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

kube-scheduler:
 file.managed:
     - name: /etc/kubernetes/scheduler
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/scheduler
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

kube-proxy-config:
   file.managed:
     - name: /etc/kubernetes/proxy
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/proxy
     - mode: 644
     - template: jinja

#kubectl-config:
#   file.managed:
#     - name: /root/.kube/config
#     - user: root
#     - group: root
#     - source: salt://master/kubernetes/cfg/kubectl-config
#     - mode: 644
#     - template: jinja
#     - makedirs: True

## Configuration file for all auth with api server ##
kubeconfig:
   file.managed:
     - name: /var/lib/kubelet/kubeconfig
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/kubeconfig
     - mode: 644
     - template: jinja
     - makedirs: True
## Token file ##
token.csv:
   file.managed:
     - name: /var/lib/kubernetes/token.csv
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/token.csv
     - mode: 644
     - template: jinja
     - makedirs: True
## Authorization policy file ##
authorization-policy.json:
   file.managed:
     - name: /var/lib/kubernetes/authorization-policy.json
     - user: root
     - group: root
     - source: salt://master/kubernetes/cfg/authorization-policy.json
     - mode: 644
     - template: jinja
     - makedirs: True

