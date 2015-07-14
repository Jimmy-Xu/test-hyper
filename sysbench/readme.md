########################################

##build
docker build -t ubuntu:sysbench .

##usage
docker run -it --name test_cpu --cpuset-cpus=0,1 --memory=2048m ubuntu:sysbench /bin/bash
docker restart 32538b49864c
docker exec -it 32538b49864c /bin/bash

##do sysbench test
 ./test.sh 1 && echo "---------" &&  ./test.sh 2


########################################

# Step 1: build docker image, create test pod
./bench.sh init

# Setp 2: see help
./bench.sh

# Step 3: auto test, output is log/cpu.log, log/mem.log, log/io.log
sudo ./bat.sh


# Step 4: generate result
./report.sh

# Step 5: view report with markdown

==========================================

COPIES=`cat /proc/cpuinfo | grep processor| wc -l`
TDS=$(($COPIES*2))
STXT=sysbenchcpu.txt
DL=+
ID="i-xxxxxx"
TYPE="t1.micro"

FN=$ID$DL$TYPE$DL$TDS$DL$STXT

sysbench --num-threads=$TDS --max-requests=30000 --test=cpu /
	--cpu-max-prime=100000 run > $FN
grep "total time:" i-*$STXT| cut -d, -f1-2 > $FN