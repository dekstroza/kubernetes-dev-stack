base:

  'roles:kube-minion':
    - match: grain
    - minion
    - etcd
    - flannel
    - docker
    - ntpd

  'roles:kube-master':
    - match: grain
    - master
    - etcd
    - flannel
    - docker
    - ntpd
    - nfs

