#!/bin/bash

# run this on a Linux machine like arldcn24,28


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 numberOfSockets (specify as 1 or 2)" 
    exit 1
fi

if [ "$1" -eq 1 ]; then
    numaopts=" --physcpubind=0 --localalloc "
    numsmp=1
    echo "Running on one socket with numactl $numaopts"
elif [ "$1" -eq 2 ]; then
    numaopts=" --physcpubind=0-1 --interleave=0,1 "
    numsmp=2
    echo "Running on two sockets with numactl $numaopts"
else
    echo "Usage: $0 numberOfSockets (specify as 1 or 2)" 
    exit 1
fi

LIBDIR=../common/vm
SSHOPTS="-p2222 -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"

# prepare source disk images
make -C $LIBDIR

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)

if [ -f vm.img ];then
  echo "found vm.img"
  TMPL="vm.img"
else
  echo "not found vm.img"
  TMPL="$LIBDIR/ubuntu-14.04-server-cloudimg-amd64-disk1.img"
fi
IMG=`mktemp tmpXXX.img`

#qemu-img create -f qcow2 -b $LIBDIR/ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG
qemu-img create -f qcow2 -b $TMPL $IMG

# start the VM & bind port 2222 on the host to port 22 in the VM
echo "sudo kvm -net nic -net user -hda $IMG -hdb $LIBDIR/seed.img -m 4G -smp $numsmp -nographic -redir :2222::22"
#numactl $numaopts kvm -net nic -net user -hda $IMG -hdb $LIBDIR/seed.img -m 4G -smp $numsmp -nographic -redir :2222::22 >$IMG.log &
#numactl $numaopts kvm -net nic -net user -hda $IMG -hdb $LIBDIR/seed.img -m 4G -smp $numsmp -nographic -redir :2222::22 
sudo kvm -net nic -net user -hda $IMG -hdb $LIBDIR/seed.img -m 4G -smp $numsmp -nographic -redir :2222::22 >$IMG.log &



# remove the overlay (qemu will keep it open as needed)
sleep 5

# build stream
make

# copy code in (we could use Ansible for this kind of thing, but...)
rsync -a -e "ssh $SSHOPTS" ./bin/ spyre@localhost:~

# annotate the log
mkdir -p results
log="results/vm.log"
now=`date`
echo "Running stream, started at $now"
echo "--------------------------------------------------------------------------------" >> $log
echo "Running stream, started at $now" >> $log

echo "TMPL: ${TMPL}"
if [[ "${TMPL}" != "vm.img" ]];then
  ssh $SSHOPTS spyre@localhost "export DEBIAN_FRONTEND=noninteractive"
  ssh $SSHOPTS spyre@localhost "sudo apt-get install -y software-properties-common"
  ssh $SSHOPTS spyre@localhost "sudo apt-get install -y python-software-properties"
  ssh $SSHOPTS spyre@localhost "sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test"
  ssh $SSHOPTS spyre@localhost "sudo apt-get -y update"
  ssh $SSHOPTS spyre@localhost "sudo apt-get -y install gcc-4.9 g++-4.9"
  ssh $SSHOPTS spyre@localhost "sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9"
  ssh $SSHOPTS spyre@localhost "sudo apt-get -y install libgomp1 numactl"
fi

# run stream and copy out results
ssh $SSHOPTS spyre@localhost "./stream.exe " >> $log

# annotate the log
echo "" >> $log
echo -n "Experiment completed at "; date

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
