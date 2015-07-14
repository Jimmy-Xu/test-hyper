#!/bin/bash

#make ubuntu-13.10-server-cloudimg-amd64-disk1.img seed.img
make ubuntu-14.04-server-cloudimg-amd64-disk1.img seed.img play-trusty.img

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG=`mktemp tmpXXX.img`
#qemu-img create -f qcow2 -b ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG
qemu-img create -f qcow2 -b ubuntu-14.04-server-cloudimg-amd64-disk1.img $IMG

# start the VM
kvm -net nic -net user -hda $IMG -hdb seed.img -m 1G -nographic -redir :2222::22 &

# remove the overlay (qemu will keep it open as needed)
sleep 2
rm $IMG

exit 0

# copy a script in (we could use Ansible for this kind of thing, but...)
rsync -a -e "ssh -p2222 -i../id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60" ../../acme-air/vagrant/install-acme-air.sh  spyre@localhost:~

# run the script
ssh -p2222 -i../id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no spyre@localhost ./install-acme-air.sh

# TODO run the benchmark

# shut down the VM
ssh -p2222 -i../id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no spyre@localhost sudo shutdown -h now
