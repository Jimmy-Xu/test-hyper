#!/bin/sh

# run this on arldcn24
# you need to be part of the kvm group; try sudo usermod -a -G kvm `whoami`

LIBDIR=../common/vm
SSHOPTS="-p2222 -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"

MNT_DIR="/mnt/data"
MNT_DEVICE="/dev/nvme0n1"

# prepare source disk images
make -C $LIBDIR


if [ -f vm.img ];then
  echo "found vm.img"
  TMPL="vm.img"
else
  echo "not found vm.img"
  TMPL="$LIBDIR/ubuntu-14.04-server-cloudimg-amd64-disk1.img"
fi

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG=`mktemp tmpXXX.img`
qemu-img create -f qcow2 -b $TMPL $IMG

# unmount ${MNT_DIR} on the host because we're going to mount it inside the VM
MOUNTED=$(mount | grep /mnt/data | wc -l)
if [ ${MOUNTED} -ne 0 ];then
	echo "${MNT_DIR} mounted, unmount first"
	sudo umount ${MNT_DIR}
	MOUNTED=$(mount | grep /mnt/data | wc -l)
	if [ ${MOUNTED} -ne 0 ];then
		echo "unmount ${MNT_DIR} failed!"
		exit 1
	else
		echo "unmount ${MNT_DIR} succeed!"
	fi
else
	echo "${MNT_DIR} already unmounted"
fi



# start the VM & bind port 2222 on the host to port 22 in the VM
# TODO use fancy virtio
sudo kvm -net nic -net user -hda $IMG -hdb $LIBDIR/seed.img \
    -drive file=${MNT_DEVICE},if=virtio,cache=none,aio=native \
    -m 1G -smp 1 -nographic -redir :2222::22 >$IMG.log &

# remove the overlay (qemu will keep it open as needed)
sleep 2

# install fio
ssh $SSHOPTS spyre@localhost sudo apt-get install -y fio

# mount ${MNT_DIR} inside the VM
ssh $SSHOPTS spyre@localhost "sudo sh -c 'mkdir -p "${MNT_DIR}" ; \
                                          mount /dev/vda "${MNT_DIR}" ; \
                                          chmod -R ugo+rwx "${MNT_DIR}"'"

echo Running fio - this takes 5-10 minutes
ssh $SSHOPTS spyre@localhost fio - < test.fio > results/vm.log

# shut down the VM
ssh $SSHOPTS spyre@localhost sudo shutdown -h now

wait

if [ -f vm.img ];then
  echo "rm tmp image $IMG"
  sudo rm $IMG -rf
else
 echo "keep vm.img"
  sudo mv $IMG vm.img
fi


echo Experiment completed
