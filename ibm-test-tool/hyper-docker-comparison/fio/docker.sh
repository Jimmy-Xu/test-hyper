#!/bin/sh

DIR=`pwd`
MNT_DIR="/mnt/data"
MNT_DEVICE="/dev/nvme0n1"

# make sure /mnt/data is mounted
MOUNTED=$(mount | grep /mnt/data | wc -l)
if [ ${MOUNTED} -eq 0 ];then
	echo "mount ${MNT_DEVICE} to ${MNT_DIR}"
	sudo mount ${MNT_DEVICE} ${MNT_DIR}
else
	echo "${MNT_DEVICE} already mount to ${MNT_DIR}"
fi

# build the container (assumes the spyre git repo is in NFS)
docker build -t fio $DIR

# run the test
echo Running fio - this takes 5-10 minutes
docker run --memory=4096m --cpuset-cpus=0 --rm -v ${MNT_DIR}:${MNT_DIR} fio test.fio > results/docker.log

wait
echo Experiment completed
