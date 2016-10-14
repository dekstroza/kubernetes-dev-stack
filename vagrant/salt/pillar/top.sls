base:
  'roles:kube-minion':
     - match: grain
     - kube-global
     - system

  'roles:kube-master':
     - match: grain
     - kube-global
     - system



