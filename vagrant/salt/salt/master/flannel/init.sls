  
flannel-config:
  file.managed:
    - name: /etc/sysconfig/flanneld
    - user: root
    - group: root
    - source: salt://master/flannel/cfg/flanneld.cfg
    - mode: 644
    - template: jinja

