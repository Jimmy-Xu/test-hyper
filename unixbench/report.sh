#!/bin/bash

LOG_DIR=log
AWK_DIR=awk

rm ${LOG_DIR}/*.tmp -rf >/dev/null 2>&1

cat ${LOG_DIR}/result.log | col -b > ${LOG_DIR}/result.log.tmp

dos2unix ${LOG_DIR}/*.tmp

echo
cat ${LOG_DIR}/result.log.tmp |awk -f ${AWK_DIR}/unixbench_report.awk
