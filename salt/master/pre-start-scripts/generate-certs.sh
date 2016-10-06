#!/bin/bash


HOST_IP=$(ip -4 -o addr show dev eth0| awk '{split($4,a,"/");print a[1]}')

function generate_ip_list {
grep -q "\- kube-master" /etc/salt/grains
if [ $? -eq 0 ]; then
	echo "\"$HOST_IP\",\"10.0.0.1\""
else
	echo "\"$HOST_IP\""
fi	
}

mkdir -p /opt/certs/$HOST_IP && cd /opt/certs/$HOST_IP
cat > $HOST_IP-csr.json <<EOF 
{
	"CN": "kubernetes",
	"hosts": [
	$(generate_ip_list)
	],
	"key": {
	"algo": "rsa",
	"size": 2048
},
"names": [
{
	"C": "IE",
	"L": "Athlone",
	"O": "Kubernetes",
	"OU": "Cluster",
	"ST": "Westmeath"
}
]
}
EOF

cfssl gencert \
	-ca=../root-ca/ca.pem \
	-ca-key=../root-ca/ca-key.pem \
	-config=../ca-config.json \
	-profile=kubernetes \
	$HOST_IP-csr.json | cfssljson -bare kubernetes

chmod +r /opt/certs/$HOST_IP/ -R

## insert copy part here ##
mkdir -p /var/lib/kubernetes

cp -f ../root-ca/ca-key.pem /var/lib/kubernetes/
cp -f ../root-ca/ca.pem /var/lib/kubernetes/
cp -f kubernetes-key.pem /var/lib/kubernetes/
cp -f kubernetes.pem /var/lib/kubernetes/
chmod +r /var/lib/kubernetes/ -R

