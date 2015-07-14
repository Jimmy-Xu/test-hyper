#!/bin/bash

SYSBENCH=/usr/local/bin/sysbench

${SYSBENCH} --version
if [ $? -ne 0 ];then
	echo "sysbench not installed, exit!"
	exit 1
fi

PARAM_NUM=7
if [ $# -ne ${PARAM_NUM} ];then
	echo "number of parameter should be ${PARAM_NUM}, but current is $#, exit"
	exit 1
fi

# echo "_MAX_REQUESTS    : $1 "
# echo "_PERCENTILE      : $2 "
# echo "_NUM_THREADS     : $3 "
# echo "_FILE_TOTAL_SIZE : $4 "
# echo "_FILE_BLOCK_SIZE : $5 "
# echo "_FILE_NUM        : $6 "
# echo "_FILE_TEST_MODE  : $7 "


#echo "start test io in hyper"
TEST_START_TS=$( date +"%s" )
TEST_START_TIME=$( date +"%F %T" )

echo "${SYSBENCH} --test=fileio --file-total-size=$4 --file-num=$6 prepare >/dev/null 2>&1 && \
${SYSBENCH} --test=fileio --max-requests=$1 --percentile=$2 --num-threads=$3 --file-total-size=$4 --file-block-size=$5 --file-num=$6 --file-test-mode=$7 run; \
${SYSBENCH} --test=fileio --file-total-size=$4 cleanup"

${SYSBENCH} --test=fileio --file-total-size=$4 --file-num=$6 prepare >/dev/null 2>&1 && \
${SYSBENCH} --test=fileio --max-requests=$1 --percentile=$2 --num-threads=$3 --file-total-size=$4 --file-block-size=$5 --file-num=$6 --file-test-mode=$7 run; \
${SYSBENCH} --test=fileio --file-total-size=$4 cleanup

TEST_END_TS=$( date +"%s" )
TEST_END_TIME=$( date +"%F %T" )
#echo
#echo "Test Start(hyper)   : ${START_TIME}"
#echo "Test End(hyper)     : ${END_TIME}"
#echo "Test Duration(hyper): $((TEST_END_TS - TEST_START_TS)) (sec)"
