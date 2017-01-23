
flannel-config:
  file.managed:
    - name: /etc/sysconfig/flanneld
    - user: root
    - group: root
    - source: salt://flannel/config-files/cfg/flanneld.cfg
    - mode: 644
    - template: jinja

