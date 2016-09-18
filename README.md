# Kubernetes Dev-Stack

## Background
Small proof of concept for running kubernetes cluster, specifically intended for development environment. Can create kubernetes cluster compromised of one master and arbitrary number of minions. Can run on Linux, Windows or Mac.

Vagrant box is based on Centos 7.2 with latest stable kernel 4.7.3, docker 1.12.1, selinux will be set to permissive mode, and firewall will be down. Intention is to keep up to date version of Centos, kernel, docker and kubernetes - should always be the latest (see bellow for more details on current versions). There are several branches with different setups of docker storage drivers and filesystems. 

#### overlay2 with xfs or ext4

Master branch has docker running with overlay2 storage driver backed by xfs.
*There are known bugs when using overlay2 with xfs (directories with ????? instead of permissions etc...), so be aware - or alternatively use overlay2 with ext4 (clone overlay2-ext4) which seems to be far more stable.*

#### zfs storage driver

You can also checkout **zfs-filesystem** branch, which has docker running with zfs storage driver. In case of zfs, kernel driver is using dkms, so do not update kernel, as it will require zfs kernel module rebuild - you have been warned !

#### lvm block device 

Or if you are fan of lvm, you can checkout *lvm-blockdevice* branch, which has lvm storage driver backed by blockdevice (keeping in mind this is just a virtual machine and blockdevice is virtual sata device added to the vm)

**This little demo was created as development environment, and should not be used in production, as kubernetes is configured with minimal security.**

### What's inside the tin can
- Centos 7.2 kernel 4.7.3, xfs, ext4, lvm or zfs
- Docker 1.12.1, overlay storage driver
- Kubernetes 1.3.6 with cluster-addons
- Flanneld 0.5.5
- Saltstack 2015.5.10 (Lithium)


### Requirements
1. [VirtualBox 5.1.4 or greater](http://www.vagrantup.com) or [Parallels 12] (http://www.parallels.com)
2. [Vagrant 1.8.5 or greater](http://www.vagrantup.com)
3. VT-x/AMD-v virtualization must be enabled in BIOS, as virtual machines run 64bit guests
4. If running in bridged mode (which is default), DHCP is expected to assign address to vagrant box(s), otherwise you can  export NETWORK_TYPE=private before starting master and minions, and they will get private addresses, and will not be accessible from outside (also they have to be on the same machine, setting access and having them on separate machines is also possible with some NAT magic, but that is beyond the scope of this little project).

### Getting started
In order to get started, first we need to start kube master, after which we can start multiple minions anywhere on the network as long as they can reach master.

#### Starting kube master
To start kubernetes master (which will also be used to schedule docker containers), do:


    cd vagrant/kube-master
    ## By default vagrant box will use 4G of RAM,
    ## to use less or more, export env variable MEM_SIZE,
    ## example: export MEM_SIZE=8096 for 8Gig VM

    ## Start the VM (or --provider=parallels)
    vagrant up --provider=virtualbox

After initial download of vagrant box (once off download) from vagrant repository, box will be automatically configured, and depending on network setup on your machine, it might ask you which network interface you wish to use - normally choose one you use to connect to Internet (normally choice #1 is what you need), but can vary depending on the machine.

Since kubernetes operates on separate network, script to create route to your newly created kubernetes cloud will be generated in the same dir (for Windows, Linux and Mac), so run:

    ## Depending on your operating system, for example Linux:

    ./add-route-LIN.sh

    ## Which will create route
    ## using your VM as gateway.


You can now ssh into your kubernetes master with:

      vagrant ssh

Kubernetes master should be up and running for you:

    ## Bellow will show you all kube memebers
    kubectl get nodes
    
    ## Bellow will show you state of cluster
    kubectl get cs
    
    ## Bellow will show everything that currently runs
    ## in kube-system namespace (dns, ui, grafana etc..)
    kubectl get po --all-namespaces

    ## Gives you cluster info, all cluster services running
    kubectl cluster-info
    
    ## You can start dns server with (continue reading to see how to change/specify your own dns domain instead of default)
    kubectl create -f /etc/kubernetes/dns/

    ## You can start kube-ui or grafana as example:
    kubectl create -f /etc/kubernetes/kubernetes-dashboard/

    ## Or Graphana:
    kubectl create -f /etc/kubernetes/grafana/

    ## And monitor progress with:
    kubectl get po --all-namespaces --watch

    ## Once up and running cluster-info will tell you where to go:

    kubectl cluster-info

    ## and open up Grafana url shown in your browser.
    ## NOTE: Due to unresolved issue, if accessing any of these urls, use http instead of https and port 8080 instead of 6443, same links cluster-info command shows just http and port 8080 - this will be resolved shortly.

Upon starting dns - depending how fast your network is, it might take a up to a minute or two for docker to pull required images. DNS server will be at 10.0.0.10 and serve domain **dekstroza.local** (read on to see how to change domain).

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

#### Starting kube minion(s) (same machine or somewhere else, as long you have network connectivity between them)

Change directory to kube-minion:

    cd kubernetes-dev-stack/vagrant/kube-minion
    ## Set the MASTER_IP env to point to your kubeernetes master

    export MASTER_IP= ip address of your master

    ## Set MEM_SIZE env if you wish more or less then 4Gig for minion(s) ##
    ## Set NUM_MINIONS=n env, where n is number of minions you wish to start ##
    ## Start the VM (or --provider=parallels) ##
    vagrant up --provider=virtualbox

Vagrant will start up your minions and salt-stack will configure them correctly. Again, depending on your network setup, you might be asked to select network interface over which minions will communicate (normally one you use to access Internet, normally choice #1).

#### Master and minions on separate machines

Since master and minions will be bridged to your host interface they can be on different hosts, only thing required is for the minions to export MASTER_IP as shown above.

#### How it works

Packer template provided in the repo is used to create vagrant box, in case you wish to create your own. Code here will use one I have already created and deployed to vagrant repository.

Salt-stack is used to configure VM upon startup, you can find configuration in salt directory.

#### Adding files into running master or minion

Vagrant will mount Vagrantfile directory inside the VM, under /vagrant path. You can use this to add more files into the box, ie pass in docker images instead of downloading them.

Happy hacking....
Dejan
