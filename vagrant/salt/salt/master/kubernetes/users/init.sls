kube-group:
  group.present:
    - system: True
kube-user:
  user.present:
    - name: kube
    - fullname: Kubernetes user
    - shell: /sbin/nologin
    - createhome: False
    - gid_from_name: True

