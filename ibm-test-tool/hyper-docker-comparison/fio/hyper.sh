#!/bin/sh

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

mkdir -p results
log="results/hyper.log"
now=`date`
echo "Running fio, started at $now"
echo "--------------------------------------------------------------------------------" >> $log
echo "Running fio, started at $now" >> $log

#sudo numactl $numaopts hyper run --cpu=1 --memory=4096 fio:latest >> $log
sudo hyper pod fio:latest >> $log

echo "" >> $log
echo -n "Experiment completed at "; date