base:
  'roles:kube-minion':
     - match: grain
     - kube-global

  'roles:kube-master':
     - match: grain
     - kube-global



