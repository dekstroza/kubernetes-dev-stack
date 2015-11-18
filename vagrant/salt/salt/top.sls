base:

  'roles:kube-minion':
    - match: grain
    - minion
    - ntpd

  'roles:kube-master':
    - match: grain
    - master
    - ntpd

