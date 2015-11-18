ntp-running:
  service.running:
    - name: ntpd 

adjust-timezone:
  cmd.run:
    - name: cp -rf /usr/share/zoneinfo/Europe/Dublin /etc/localtime
    - unless: cmp /usr/share/zoneinfo/Europe/Dublin /etc/localtime

