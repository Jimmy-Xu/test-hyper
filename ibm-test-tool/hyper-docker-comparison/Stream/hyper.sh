#!/bin/sh

mkdir -p results
log="results/hyper.log"
now=`date`
echo "Running stream, started at $now"
echo "--------------------------------------------------------------------------------" >> $log
echo "Running stream, started at $now" >> $log

#sudo numactl $numaopts hyper run --cpu=1 --memory=4096 stream:latest >> $log
sudo hyper run --cpu=1 --memory=4096 stream:latest >> $log

echo "" >> $log
echo -n "Experiment completed at "; date