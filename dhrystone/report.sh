#!/bin/bash

LOG_DIR=log
AWK_DIR=awk

rm ${LOG_DIR}/*.tmp -rf >/dev/null 2>&1

cat ${LOG_DIR}/cpu.log | col -b > ${LOG_DIR}/cpu.log.tmp

dos2unix ${LOG_DIR}/*.tmp

echo
cat ${LOG_DIR}/cpu.log.tmp | grep -A24 "CPU Performance Test -" | awk -f ${AWK_DIR}/cpu_report.awk
