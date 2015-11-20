#!/bin/bash

### add route command for OSX
echo -e "sudo route -n delete 10.0.0.0/16 \nsudo route -n add 10.0.0.0/16 $1" > /vagrant/add-route-osX.sh && chmod +x /vagrant/add-route-osX.sh
### add route command for LINUX
echo -e "sudo route del -net 10.0.0.0/16 \nsudo route add -net 10.0.0.0/16 gw $1" > /vagrant/add-route-LIN.sh && chmod +x /vagrant/add-route-LIN.sh
### add route command for WINDOWS
echo -e "route delete 10.0.0.0 mask 255.255.0.0 & route add 10.0.0.0 mask 255.255.0.0 $1" > /vagrant/add-route-WIN.bat

echo "#################################################################################"
echo "# Please create route to your cloud by running:                                 #"
echo "# 1. For MacOS, please run:   add-route-osX.sh                                  #"
echo "# 2. For Linux, please run:   add-route-LIN.sh                                  #"
echo "# 3. For Windows, please run: add-route-WIN.bat                                 #"
echo "#                                                                               #"
echo "#             SSH into machine with vagrant ssh command                         #"
echo "#                         ~Have fun, Dejan~                                     #"
echo "#################################################################################"

