#!/bin/bash
####################################
#
# Please read and modify this file carfully befor running it
#
####################################

# remove this line once you read and modify this file
exit 1

# install ssh keys of ovirt and gluster
# paste your keys here
echo "ssh-rsa [...] ovirt-engine" >> /root/.ssh/authorized_keys
echo "ssh-rsa [...] gdeploy" >> /root/.ssh/authorized_keys

# enable required repos
subscription-manager repos --disable="*"
subscription-manager repos --enable="rhel-7-server-rhv-4-mgmt-agent-rpms"
subscription-manager repos --enable="rhel-7-server-rpms"
subscription-manager repos --enable="rh-gluster-3-for-rhel-7-server-rpms"

# install gluster
yum install glusterfs-server bash-completion

# fix network
echo "GATEWAYDEV=ovirtmgmt" > /etc/sysconfig/network

# disable multipath
cat >> /etc/multipath.conf <<- EOF
# inserted by disable-multipath.sh

blacklist {
        devnode "*"
}
EOF
multipath -F
systemctl restart multipathd.service

# clean partition table
for i in {b,c,d,e} ; do
dd if=/dev/zero of=/dev/sd$i bs=1M count=100
done

# now install ovirt host engine via ovirt ui
# and setup gluster
