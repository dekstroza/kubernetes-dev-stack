# Heat template for simple kubernetes deployment on OpenStack


## Backrgound
This branch contains salt configuration and heat template which can deploy kubernetes on OpenStack. In order to run it, you will need
VM image with kubernetes binaries and saltstack. This branch will have packer configuration to build the VM image soon, or alternatively
you can use my image from here: http://dekstroza.io/kubernetes.img


## How to run

On your OpenStack project create ssh key that you will use, make sure you have floating ip pool (you will need only one floating ip) and update
example-env.yaml with the details, removing all comments.

Source your openstack rc file, and run with: 

```openstack stack create -e your-env.yaml -t kubernetes-stack.yaml DESIRED_STACK_NAME```

This will create the stack with defaults specified in your env yaml file. 
To see location of dashboard, grafana etc:

```openstack stack show DESIRED_STACK_NAME``` 

## How it works

Two heat fragments contain definition for master and minions. When spawn and started cloud-init is instructed to clone this branch and use
saltstack configuration from salt and pillar, it is more less the same as one used for vagrant on master branch (same configuration applies)

After the repo is cloned saltstack will run and configure everything.

Happy hacking,
Dejan
