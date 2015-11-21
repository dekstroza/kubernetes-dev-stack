# Kubernetes Dev-Stack

## Background
Small proof of concept for running kubernetes cluster, specifically intended for development environment. Can create kubernetes cluster compromised of one master and arbitrary number of minions. Can run on Linux, Windows or Mac. Vagrant box is based on Centos 7.1 with latest stable kernel 4.3.0, docker 1.8.2 using overlay storage driver, backed by xfs file system, kubernetes is at the latest version 1.1.1. SELinux will be set to permissive mode, and firewall will be down.
Master and Minion(s) will be bridged by default to one of your host interfaces, so assumption is there is DHCP somwhere on your network which will give your VM ip address. If this is not the case, you won't be able to run it.


**This is little demo was created for the purpose of development, and should not be used in production, as kubernetes is configured without security.**

### What's inside the tin can
- Centos 7.1 kernel 4.3.0, xfs
- Docker 1.8.2, overlay storage driver
- Kubernetes 1.1.1 with cluster-addons
- Saltstack 2015.5.5-1


### Requirements
1. VirtualBox, recent version, you can get it here: [Oracle Virtual box](http://www.vagrantup.com)
2. Vagrant, recent version, you can get it from here: [Vagrant](http://www.vagrantup.com)
3. If running in bridged mode (which is default), DHCP is expected to assign address to vagrant box, otherwise setting env     variable NETWORK_TYPE=private will do the trick, however your kube master/minions will not be accessible from outside. 

### Getting started
In order to get started, first we need to start kube master, after which we can start multiple minions anywhere on the network as long as they can reach master.

#### Starting kube master
To start kubernetes master (which will also be used to schedule docker containers), do:


    cd vagrant/kube-master
    ## By default vagrant box will use 4G of RAM,
    ## to use less or more, export env variable MEM_SIZE,
    ## example: export MEM_SIZE=8096 for 8Gig VM

    ## Start the VM
    vagrant up --provider=virtualbox

After initial download of vagrant box (once off download, 450Mb) from vagrant repository, box will be automatically configured, and depending on network setup on your machine, it might ask you which network interface you wish to use - normally choose one you use to connect to Internet (normally choice #1 is what you need), but can vary depending on the machine.

Since kubernetes operates on separate network, script to create route to your newly created kubernetes cloud will be generated in the same dir (for Windows, Linux and Mac), so run:

    ## Depending on your os, for example Linux:

    ./add-route-LIN.sh

    ## Which will create route
    ## using your VM as gateway.


You can now ssh into your kubernetes master with:

      vagrant ssh

Kubernetes master should be up and running for you:

    ## Bellow will show you all kube memebers
    kubectl get nodes

    ## Bellow will show everything that currently Requirements
    ## in kube-system namespace (dns, ui, grafana etc..)
    kubectl get po --namespace=kube-system

    ## Gives you cluster info, all cluster services running
    kubectl cluster-info

    ## You can start kube-ui or grafana as example:
    sudo kubectl create -f /etc/kubernetes/kube-ui/

    ## Or Graphana:
    sudo kubectl create -f /etc/kubernetes/grafana/

    ## And monitor progress with:
    watch -n 5 kubectl get po --namespace=kube-system

    ## Once up and running cluster-info will tell you where to go:

    kubectl cluster-info

    ## and open up Grafana url shown in your browser.

Also there will be dns up and running - depending how fast your network is, it might take a few for docker to pull required images. DNS server will be at 10.0.0.10 and serve domain **dekstroza.local**

To verify dns is up and running, inside master or minions, run:

    dig @10.0.0.10 kuberenetes.default.svc.dekstroza.local

If you have added route as described above, dns will be reachable  not only from inside the VM, but also from your host OS.
You can find configuration for it in salt/pillar/kube-global.sls
and set different cluster CIDR, service CIDR, DNS domain or DNS IP address. After changing any of these, running salt-stack can reconfigure your already running VM, but I would recommend to restart your VMs (master and minions).
Bellow is current content:

    ## cat kube-global.sls:
    service_cluster_cidr: 10.0.0.0/16
    kube_cluster_cidr: 10.244.0.0/16
    dns_replicas: 1
    dns_server: 10.0.0.10
    dns_domain: dekstroza.local
    cluster_registry_disk_size: 1G

Important bits are:
- service_cluster_cidr : Range from which kuberentes nodes will     get address for internal communication
- kube_cluster_cidr : Range from which services in kubernetes will get address
- dns_replicas : Number of DNS server replicas
- dns_server : IP that will be assigned to DNS server
- dns_domain : Chosen DNS domain
- cluster_registry_disk_size : Internal docker registry disk size

*Note cluster_registry_disk_size is not used and has not been tested*

#### Starting kube minion(s)

Change directory to kube-minion:

    cd kubernetes-dev-stack/vagrant/kube-minion
    ## Set the MASTER_IP to point to your kubeernetes master

    export MASTER_IP= ip address of your master

    ## Set MEM_SIZE if you wish more or less then 4Gig for ## minion(s)
    ## Set NUM_MINIONS=n, where n is number of minions you wish to ## start

Vagrant will start up your minions and salt-stack will configure them correctly. Again, depending on your network setup, you might be asked to select network interface over which minions will communicate (normally one you use to access Internet, normally choice #1).

#### Master and minions on separate machines

Since master and minions will be bridged to your host interface they can be on different hosts, only thing required is for the minions to export MASTER_IP as shown above.

#### How it works

Packer template provided in the repo is used to create vagrant box, in case you wish to create your own. Code here will use one I have already created and deployed to vagrant repository.

Salt-stack is used to configure VM upon startup, you can find configuration in salt directory.

#### Adding files into running master or minion

Vagrant will mount directory where Vagrantfile is located inside the VM, under /vagrant path. You can use this to add more files into the box, ie pass in docker images instead of downloading them.

Happy hacking....
Dejan
